class Pdnsrec < Formula
  desc "Non-authoritative/recursing DNS server"
  homepage "https://www.powerdns.com/recursor.html"
  url "https://downloads.powerdns.com/releases/pdns-recursor-4.2.1.tar.bz2"
  sha256 "8d8c3235cc5281f0fc51946129f22758778f4c50bfda095d5856feb4c756891f"

  bottle do
    sha256 "deeed735fefd99d65289614e3ff8730c71248bdc2218dd1803f3c775df5775b3" => :catalina
    sha256 "700f8316d4b5770dd7764b2a60220a5c7ec239d044280f2436c97432a71d6327" => :mojave
    sha256 "a1cf1c5231fcea9c0a48f928e4479c60627d4823557db01b21c8c9c79be68240" => :high_sierra
    sha256 "531adab0998084f2e66923b2429c5b4c446970d222b6e1b38c71eadcbd5711b3" => :sierra
  end

  depends_on "pkg-config" => :build
  depends_on "boost"
  depends_on "gcc" if DevelopmentTools.clang_build_version == 600
  depends_on "lua"
  depends_on "openssl@1.1"

  def install
    ENV.cxx11

    args = %W[
      --prefix=#{prefix}
      --sysconfdir=#{etc}/powerdns
      --disable-silent-rules
      --with-boost=#{Formula["boost"].opt_prefix}
      --with-libcrypto=#{Formula["openssl@1.1"].opt_prefix}
      --with-lua
      --without-net-snmp
    ]

    system "./configure", *args
    system "make", "install"
  end

  test do
    output = shell_output("#{sbin}/pdns_recursor --version 2>&1")
    assert_match "PowerDNS Recursor #{version}", output
  end
end
