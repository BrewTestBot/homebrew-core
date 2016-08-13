# This formula tracks GnuPG stable. You can find GnuPG Modern via:
# brew install homebrew/versions/gnupg21
# At the moment GnuPG Modern causes too many incompatibilities to be in core.
class Gnupg2 < Formula
  desc "GNU Privacy Guard: a free PGP replacement"
  homepage "https://www.gnupg.org/"
  url "https://gnupg.org/ftp/gcrypt/gnupg/gnupg-2.0.30.tar.bz2"
  mirror "https://www.mirrorservice.org/sites/ftp.gnupg.org/gcrypt/gnupg/gnupg-2.0.30.tar.bz2"
  sha256 "e329785a4f366ba5d72c2c678a7e388b0892ac8440c2f4e6810042123c235d71"
  revision 2

  bottle do
    sha256 "882ef78e26c022182104d9038080ea0d8a4057ba024aca259770c31c7e3a0fd5" => :el_capitan
    sha256 "6e8abac4ae122b68ef643fb76d1ab0ec7567ab92603d1741436005f23a313a08" => :yosemite
    sha256 "a2b091b465af0b95a192c8f3c99503663cd1b3fca29fc6ddd99e22a8601fe496" => :mavericks
  end

  depends_on "libgpg-error"
  depends_on "libgcrypt"
  depends_on "libksba"
  depends_on "libassuan"
  depends_on "pinentry"
  depends_on "pth"
  depends_on "gpg-agent"
  depends_on "curl" if MacOS.version <= :mavericks
  depends_on "dirmngr" => :recommended
  depends_on "libusb-compat" => :recommended
  depends_on "readline" => :optional

  def install
    # Adjust package name to fit our scheme of packaging both gnupg 1.x and
    # 2.x, and gpg-agent separately, and adjust tests to fit this scheme
    inreplace "configure" do |s|
      s.gsub! "PACKAGE_NAME='gnupg'", "PACKAGE_NAME='gnupg2'"
      s.gsub! "PACKAGE_TARNAME='gnupg'", "PACKAGE_TARNAME='gnupg2'"
    end
    inreplace "tests/openpgp/Makefile.in" do |s|
      s.gsub! "required_pgms = ../../g10/gpg2 ../../agent/gpg-agent",
              "required_pgms = ../../g10/gpg2"
      s.gsub! "../../agent/gpg-agent --quiet --daemon sh",
              "gpg-agent --quiet --daemon sh"
    end

    ENV.append "LDFLAGS", "-lresolv"

    ENV["gl_cv_absolute_stdint_h"] = "#{MacOS.sdk_path}/usr/include/stdint.h"

    agent = Formula["gpg-agent"].opt_prefix

    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --sbindir=#{bin}
      --enable-symcryptrun
      --disable-agent
      --with-agent-pgm=#{agent}/bin/gpg-agent
      --with-protect-tool-pgm=#{agent}/libexec/gpg-protect-tool
    ]

    if build.with? "readline"
      args << "--with-readline=#{Formula["readline"].opt_prefix}"
    end

    system "./configure", *args
    system "make"
    system "make", "check"
    system "make", "install"

    # Add symlinks from gpg2 to unversioned executables, replacing gpg 1.x.
    bin.install_symlink "gpg2" => "gpg"
    bin.install_symlink "gpgv2" => "gpgv"
    man1.install_symlink "gpg2.1" => "gpg.1"
    man1.install_symlink "gpgv2.1" => "gpgv.1"

    # Gpg-zip isn't installed by this formula.
    rm_f man1/"gpg-zip.1"
  end

  def post_install
    (var/"run").mkpath
  end

  test do
    Gpg.create_test_key(testpath)
    (testpath/"test.txt").write "Hello World!"
    system bin/"gpg", "--armor", "--sign", "test.txt"
    system bin/"gpg", "--verify", "test.txt.asc"
  end
end
