class NetSnmp < Formula
  desc "Implements SNMP v1, v2c, and v3, using IPv4 and IPv6"
  homepage "http://www.net-snmp.org/"
  url "https://downloads.sourceforge.net/project/net-snmp/net-snmp/5.7.3/net-snmp-5.7.3.tar.gz"
  sha256 "12ef89613c7707dc96d13335f153c1921efc9d61d3708ef09f3fc4a7014fb4f0"

  bottle do
    revision 3
    sha256 "5529c44da0f73dcafb3c522c404917442f6ea227123267ebb5a176a269c0148a" => :el_capitan
    sha256 "719def60ff0599c8a7338a95f1591a626be2bf0d4c2b0255bc4a24bf8eb92181" => :yosemite
    sha256 "84522072bdc9581c8c1e822add3b35addcf0e842802d36f3a58edeee8d678f86" => :mavericks
  end

  keg_only :provided_by_osx

  depends_on "openssl"
  depends_on :python => :optional

  def install
    args = [
      "--disable-debugging",
      "--prefix=#{prefix}",
      "--enable-ipv6",
      "--with-defaults",
      "--with-persistent-directory=#{var}/db/net-snmp",
      "--with-logfile=#{var}/log/snmpd.log",
      "--with-mib-modules=host ucd-snmp/diskio",
      "--without-rpm",
      "--without-kmem-usage",
      "--disable-embedded-perl",
      "--without-perl-modules",
    ]

    if build.with? "python"
      args << "--with-python-modules"
      ENV["PYTHONPROG"] = `which python`
    end

    # https://sourceforge.net/p/net-snmp/bugs/2504/
    ln_s "darwin13.h", "include/net-snmp/system/darwin14.h"
    ln_s "darwin13.h", "include/net-snmp/system/darwin15.h"

    system "./configure", *args
    system "make"
    system "make", "install"
  end
end
