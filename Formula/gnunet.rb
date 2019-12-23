class Gnunet < Formula
  desc "Framework for distributed, secure and privacy-preserving applications"
  homepage "https://gnunet.org/"
  url "https://ftp.gnu.org/gnu/gnunet/gnunet-0.12.0.tar.gz"
  sha256 "2184ace2960e4757969f3cd6bc0dba6f136871bf7bcca5d80a7147bde0d2e0af"

  bottle do
    cellar :any
    sha256 "38c4d3f3877e07196a601ac53b0116dbdcc1e7e83974c50da06b01adf186db64" => :catalina
    sha256 "784e76dcfd81191a61144267be38427bba50930189ef51e433034e29058c0e0a" => :mojave
    sha256 "7066f3e079af3ed4a41a78dee0caad3dd8d16813b3456f0237f30393dee5650a" => :high_sierra
  end

  depends_on "pkg-config" => :build
  depends_on "gettext"
  depends_on "gnutls"
  depends_on "jansson"
  depends_on "libextractor"
  depends_on "libgcrypt"
  depends_on "libidn2"
  depends_on "libmicrohttpd"
  depends_on "libmpc"
  depends_on "libunistring"
  depends_on "unbound"

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    output = shell_output("#{bin}/gnunet-config -s arm")
    assert_match "BINARY = gnunet-service-arm", output
  end
end
