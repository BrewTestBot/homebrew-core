class Exempi < Formula
  desc "Library to parse XMP metadata"
  homepage "https://wiki.freedesktop.org/libopenraw/Exempi/"
  url "https://libopenraw.freedesktop.org/download/exempi-2.4.5.tar.bz2"
  sha256 "406185feb88e84ea1d4b4251370be2991205790d7113a7e28e192ff46a4f221e"

  bottle do
    cellar :any
    sha256 "38ea47dd4aa6ba60039ffc10c57b71dfeebd11f4ea4504c536f513e047f2caf6" => :high_sierra
    sha256 "9d9150d0bc98637f83d3f41805094f34c937659f10dfef110ce9bdeb379f17dc" => :sierra
    sha256 "4e9be935ecef717a08b180f753d4321388cb1979113d6a08024df0a54a29581e" => :el_capitan
  end

  depends_on "boost"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--with-boost=#{HOMEBREW_PREFIX}"
    system "make", "install"
  end
end
