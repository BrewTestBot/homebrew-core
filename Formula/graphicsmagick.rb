class Graphicsmagick < Formula
  desc "Image processing tools collection"
  homepage "http://www.graphicsmagick.org/"
  url "https://downloads.sourceforge.net/project/graphicsmagick/graphicsmagick/1.3.26/GraphicsMagick-1.3.26.tar.xz"
  sha256 "fba015f3d5e5d5f17e57db663f1aa9d338e7b62f1d415b85d13ee366927e5f88"
  revision 1
  head "http://hg.code.sf.net/p/graphicsmagick/code", :using => :hg

  bottle do
    rebuild 2
    sha256 "3f6ae9a34f0b3ee7d02bda4548d04f80262b4fe9fac87c3f0d3b81f8ea9c70d5" => :high_sierra
    sha256 "08f4ed4f2364bf62ff3e9a4070315876e85192ec34f1183a0a1007f519a2ffb2" => :sierra
    sha256 "9ed8937b049019bf0411c2e66787eeb61254a3cbf71bbecf92cba69b92a25a48" => :el_capitan
  end

  option "without-magick-plus-plus", "disable build/install of Magick++"
  option "without-svg", "Compile without svg support"
  option "with-perl", "Build PerlMagick; provides the Graphics::Magick module"
  option "with-jp2", "Compile with jp2 support"

  depends_on "pkg-config" => :build
  depends_on "libtool" => :run
  depends_on "jpeg" => :recommended
  depends_on "libpng" => :recommended
  depends_on "libtiff" => :recommended
  depends_on "freetype" => :recommended
  depends_on "little-cms2" => :optional
  depends_on "jasper" => :optional
  depends_on "libwmf" => :optional
  depends_on "ghostscript" => :optional
  depends_on "webp" => :optional
  depends_on :x11 => :optional

  skip_clean :la

  def ghostscript_fonts?
    File.directory? "#{HOMEBREW_PREFIX}/share/ghostscript/fonts"
  end

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --enable-shared
      --disable-static
      --with-modules
      --without-lzma
      --disable-openmp
      --with-quantum-depth=16
    ]

    args << "--without-gslib" if build.without? "ghostscript"
    args << "--with-gs-font-dir=#{HOMEBREW_PREFIX}/share/ghostscript/fonts" if build.without? "ghostscript"
    args << "--without-magick-plus-plus" if build.without? "magick-plus-plus"
    args << "--with-perl" if build.with? "perl"
    args << "--with-webp=yes" if build.with? "webp"
    args << "--without-x" if build.without? "x11"
    args << "--without-ttf" if build.without? "freetype"
    args << "--without-xml" if build.without? "svg"
    args << "--without-lcms2" if build.without? "little-cms2"
    args << "--with-jp2" if build.with? "jp2"

    # versioned stuff in main tree is pointless for us
    inreplace "configure", "${PACKAGE_NAME}-${PACKAGE_VERSION}", "${PACKAGE_NAME}"
    system "./configure", *args
    system "make", "install"
    if build.with? "perl"
      cd "PerlMagick" do
        # Install the module under the GraphicsMagick prefix
        system "perl", "Makefile.PL", "INSTALL_BASE=#{prefix}"
        system "make"
        system "make", "install"
      end
    end
  end

  def caveats
    if build.with? "perl"
      <<~EOS
        The Graphics::Magick perl module has been installed under:

          #{lib}

      EOS
    end
  end

  test do
    fixture = test_fixtures("test.png")
    assert_match "PNG 8x8+0+0", shell_output("#{bin}/gm identify #{fixture}")
  end
end
