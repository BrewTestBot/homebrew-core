# This formula tracks 1.0.2 branch of OpenSSL, not the 1.1.0 branch. Due to
# significant breaking API changes in 1.1.0 other formulae will be migrated
# across slowly, so core will ship `openssl` & `openssl@1.1` for foreseeable.
class Openssl < Formula
  desc "SSL/TLS cryptography library"
  homepage "https://openssl.org/"
  url "https://www.openssl.org/source/openssl-1.0.2p.tar.gz"
  mirror "https://dl.bintray.com/homebrew/mirror/openssl--1.0.2p.tar.gz"
  mirror "https://www.mirrorservice.org/sites/ftp.openssl.org/source/openssl-1.0.2p.tar.gz"
  mirror "http://artfiles.org/openssl.org/source/openssl-1.0.2p.tar.gz"
  sha256 "50a98e07b1a89eb8f6a99477f262df71c6fa7bef77df4dc83025a2845c827d00"

  bottle do
    rebuild 1
    sha256 "43e3fca9a7f25fc005759d191dcfbeaa1d82ddd36ba24a07419491ac3580403f" => :mojave
    sha256 "86cffe1ca0a291ea7258517e113df2037a8518ba2666b8d9f75d4be805dfca27" => :high_sierra
    sha256 "407df9bf005cdf58f6eecd39e02cbfd6c905606da92301428094052bf3b18790" => :sierra
  end

  keg_only :provided_by_macos,
    "Apple has deprecated use of OpenSSL in favor of its own TLS and crypto libraries"

  option "without-test", "Skip build-time tests (not recommended)"

  deprecated_option "without-check" => "without-test"

  # An updated list of CA certificates for use by Leopard, whose built-in certificates
  # are outdated, and Snow Leopard, whose `security` command returns no output.
  resource "ca-bundle" do
    url "https://curl.haxx.se/ca/cacert-2018-10-17.pem"
    mirror "http://gitcdn.xyz/cdn/paragonie/certainty/d3e2777e1ca2b1401329a49c7d56d112e6414f23/data/cacert-2018-10-17.pem"
    sha256 "86695b1be9225c3cf882d283f05c944e3aabbc1df6428a4424269a93e997dc65"
  end

  # Use standard env on Snow Leopard to allow compilation fix below to work.
  env :std if MacOS.version == :snow_leopard

  def arch_args
    {
      :x86_64 => %w[darwin64-x86_64-cc enable-ec_nistp_64_gcc_128],
      :i386   => %w[darwin-i386-cc],
    }
  end

  def configure_args; %W[
    --prefix=#{prefix}
    --openssldir=#{openssldir}
    no-ssl2
    no-ssl3
    no-zlib
    shared
    enable-cms
  ]
  end

  def install
    # OpenSSL will prefer the PERL environment variable if set over $PATH
    # which can cause some odd edge cases & isn't intended. Unset for safety,
    # along with perl modules in PERL5LIB.
    ENV.delete("PERL")
    ENV.delete("PERL5LIB")

    if MacOS.prefer_64_bit?
      arch = Hardware::CPU.arch_64_bit
    else
      arch = Hardware::CPU.arch_32_bit
    end

    # Keep Leopard/Snow Leopard support alive for things like building portable Ruby by
    # avoiding a makedepend issue introduced in recent versions of OpenSSL 1.0.2.
    # https://github.com/Homebrew/homebrew-core/pull/34326
    depend_args = (MacOS.version <= :snow_leopard) ? ["MAKEDEPPROG=cc"] : []

    # Build with GCC on Snow Leopard, which errors during tests if built with its clang.
    # https://github.com/Homebrew/homebrew-core/issues/2766
    args = (MacOS.version == :snow_leopard) ? ["CC=cc"] : []

    ENV.deparallelize
    system "perl", "./Configure", *(configure_args + arch_args[arch])
    system "make", "depend", *depend_args
    system "make", *args
    system "make", "test" if build.with?("test")

    system "make", "install", "MANDIR=#{man}", "MANSUFFIX=ssl"
  end

  def openssldir
    etc/"openssl"
  end

  def post_install
    keychains = %w[
      /System/Library/Keychains/SystemRootCertificates.keychain
    ]

    certs_list = `security find-certificate -a -p #{keychains.join(" ")}`
    certs = certs_list.scan(
      /-----BEGIN CERTIFICATE-----.*?-----END CERTIFICATE-----/m,
    )

    valid_certs = certs.select do |cert|
      IO.popen("#{bin}/openssl x509 -inform pem -checkend 0 -noout", "w") do |openssl_io|
        openssl_io.write(cert)
        openssl_io.close_write
      end

      $CHILD_STATUS.success?
    end

    openssldir.mkpath
    if MacOS.version <= :snow_leopard
      resource("ca-bundle").stage do
        openssldir.install "cacert-#{resource("ca-bundle").version}.pem" => "cert.pem"
      end
    else
      (openssldir/"cert.pem").atomic_write(valid_certs.join("\n"))
    end
  end

  def caveats; <<~EOS
    A CA file has been bootstrapped using certificates from the SystemRoots
    keychain. To add additional certificates (e.g. the certificates added in
    the System keychain), place .pem files in
      #{openssldir}/certs

    and run
      #{opt_bin}/c_rehash
  EOS
  end

  test do
    # Make sure the necessary .cnf file exists, otherwise OpenSSL gets moody.
    assert_predicate HOMEBREW_PREFIX/"etc/openssl/openssl.cnf", :exist?,
            "OpenSSL requires the .cnf file for some functionality"

    # Check OpenSSL itself functions as expected.
    (testpath/"testfile.txt").write("This is a test file")
    expected_checksum = "e2d0fe1585a63ec6009c8016ff8dda8b17719a637405a4e23c0ff81339148249"
    system "#{bin}/openssl", "dgst", "-sha256", "-out", "checksum.txt", "testfile.txt"
    open("checksum.txt") do |f|
      checksum = f.read(100).split("=").last.strip
      assert_equal checksum, expected_checksum
    end
  end
end
