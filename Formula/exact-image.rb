class ExactImage < Formula
  desc "Image processing library"
  homepage "https://exactcode.com/opensource/exactimage/"
  url "https://dl.exactcode.de/oss/exact-image/exact-image-1.0.2.tar.bz2"
  sha256 "0694c66be5dec41377acead475de69b3d7ffb42c702402f8b713f8b44cdc2791"

  bottle do
    rebuild 1
    sha256 "3c2f60adaefd294c52d8e55c5781eed44b93382776cb08b898a4b02b708954fe" => :mojave
    sha256 "d9a2cdd3a88e19bb6e3c0f4c1712d58b80b4003b3fe676186a90a0e3827cb556" => :high_sierra
    sha256 "22d98724dae572e22a2801ee3a5675d393588364ff5c950a0d323a6ca6411ecd" => :sierra
  end

  depends_on "pkg-config" => :build
  depends_on "libagg"

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "#{bin}/bardecode"
  end
end
