class Libfabric < Formula
  desc "OpenFabrics libfabric"
  homepage "https://ofiwg.github.io/libfabric/"
  url "https://github.com/ofiwg/libfabric/releases/download/v1.7.2/libfabric-1.7.2.tar.bz2"
  sha256 "cda00244d1366462a5a020ad8f78782d3e171ec598c408aaeac68a3b5d439f21"
  head "https://github.com/ofiwg/libfabric.git"

  bottle do
    cellar :any
    sha256 "958a3ebbe725be48354eb85c857defda862b62bcc091d6f4fc520e31db72fc14" => :mojave
    sha256 "684433ce8f87a62b80ae6599633ee90792787bf9f556b4dde314ff5333653ef8" => :high_sierra
    sha256 "769ee2d5d437a57b45b979c64e2a34528015648a9afc9c8c2db72d33ca819370" => :sierra
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool"  => :build

  def install
    system "autoreconf", "-fiv"
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "#(bin}/fi_info"
  end
end
