class Openslide < Formula
  desc "C library to read whole-slide images (a.k.a. virtual slides)"
  homepage "https://openslide.org/"
  url "https://github.com/openslide/openslide/releases/download/v3.4.1/openslide-3.4.1.tar.xz"
  sha256 "9938034dba7f48fadc90a2cdf8cfe94c5613b04098d1348a5ff19da95b990564"
  revision 4

  bottle do
    cellar :any
    rebuild 1
    sha256 "9cafdc09ef783c6935bc9d2e0210a962741c280677bb3de3d70052caa655f03a" => :high_sierra
    sha256 "40f4bc12659271a1681ab45abb72c6f6beb56fa5f661d71441c9b3f838f80085" => :sierra
    sha256 "4b23a5bde0d2ade582237e7baa8c02220e90f7d2ff8ea0ed799fdc6423e18d15" => :el_capitan
  end

  depends_on "pkg-config" => :build
  depends_on "libpng"
  depends_on "jpeg"
  depends_on "libxml2"
  depends_on "libtiff"
  depends_on "glib"
  depends_on "openjpeg"
  depends_on "cairo"
  depends_on "gdk-pixbuf"

  resource "svs" do
    url "http://openslide.cs.cmu.edu/download/openslide-testdata/Aperio/CMU-1-Small-Region.svs"
    sha256 "ed92d5a9f2e86df67640d6f92ce3e231419ce127131697fbbce42ad5e002c8a7"
  end

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    resource("svs").stage do
      system bin/"openslide-show-properties", "CMU-1-Small-Region.svs"
    end
  end
end
