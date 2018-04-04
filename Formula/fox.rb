class Fox < Formula
  desc "Toolkit for developing Graphical User Interfaces easily"
  homepage "http://www.fox-toolkit.org/"
  url "http://fox-toolkit.org/ftp/fox-1.6.57.tar.gz"
  sha256 "65ef15de9e0f3a396dc36d9ea29c158b78fad47f7184780357b929c94d458923"

  bottle do
    cellar :any
    sha256 "1de9a326c1e14cf8c4f29768478deb14071ace6120e4dca6557e6872fd88e7dd" => :high_sierra
    sha256 "14435c5f78a3d046ca5a0890edafc71cd74335c0857e8701fe26ae481977aeb2" => :sierra
    sha256 "a12e69c87858187ed33f11713e06c98a482308b3cb78884441ba279f4f51523e" => :el_capitan
  end

  depends_on :x11
  depends_on "fontconfig"
  depends_on "freetype"
  depends_on "libpng"
  depends_on "jpeg"
  depends_on "libtiff"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--enable-release",
                          "--prefix=#{prefix}",
                          "--with-x",
                          "--with-opengl"
    # Fix undefined symbols error for MPCreateSemaphore, MPDeleteSemaphore, etc.
    system "make", "install", "LDFLAGS=-framework CoreServices"
    rm bin/"Adie.stx"
  end

  test do
    system bin/"reswrap", "-t", "-o", "text.txt", test_fixtures("test.jpg")
    assert_match "\\x00\\x85\\x80\\x0f\\xae\\x03\\xff\\xd9", File.read("text.txt")
  end
end
