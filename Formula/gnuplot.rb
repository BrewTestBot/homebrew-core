class Gnuplot < Formula
  desc "Command-driven, interactive function plotting"
  homepage "http://www.gnuplot.info/"
  url "https://downloads.sourceforge.net/project/gnuplot/gnuplot/5.2.5/gnuplot-5.2.5.tar.gz"
  sha256 "039db2cce62ddcfd31a6696fe576f4224b3bc3f919e66191dfe2cdb058475caa"

  bottle do
    rebuild 1
    sha256 "ff83c77a7e572d0e4d1891ea9a8cd9b55209a0605570c88301a34f24be84ead6" => :mojave
    sha256 "2985c36df84d458cfddda05271b6096ef3b22bec6e80f7f08595221bc7d7b2d1" => :high_sierra
    sha256 "b5f65cc12b6a22b6a90321b8756f954b099d64cff1e386d83d21639566d70256" => :sierra
  end

  head do
    url "https://git.code.sf.net/p/gnuplot/gnuplot-main.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  option "with-aquaterm", "Build with AquaTerm support"
  option "with-wxmac", "Build with wxmac support"

  deprecated_option "qt" => "with-qt"
  deprecated_option "with-qt5" => "with-qt"
  deprecated_option "with-x" => "with-x11"
  deprecated_option "wx" => "with-wxmac"

  depends_on "pkg-config" => :build
  depends_on "gd"
  depends_on "lua"
  depends_on "pango"
  depends_on "readline"
  depends_on "qt" => :optional
  depends_on "wxmac" => :optional
  depends_on :x11 => :optional

  needs :cxx11 if build.with? "qt"

  resource "libcerf" do
    url "https://www.mirrorservice.org/sites/distfiles.macports.org/libcerf/libcerf-1.5.tgz"
    sha256 "e36dc147e7fff81143074a21550c259b5aac1b99fc314fc0ae33294231ca5c86"
  end

  def install
    # Qt5 requires c++11 (and the other backends do not care)
    ENV.cxx11 if build.with? "qt"

    if build.with? "aquaterm"
      # Add "/Library/Frameworks" to the default framework search path, so that an
      # installed AquaTerm framework can be found. Brew does not add this path
      # when building against an SDK (Nov 2013).
      ENV.prepend "CPPFLAGS", "-F/Library/Frameworks"
      ENV.prepend "LDFLAGS", "-F/Library/Frameworks"
    end

    # gnuplot is not yet compatible with More recent libcerf:
    # https://sourceforge.net/p/gnuplot/bugs/2077/
    # In next release, we can remove this and depend on the libcerf formula.
    resource("libcerf").stage do
      system "./configure", "--prefix=#{buildpath}/libcerf", "--enable-static", "--disable-shared"
      system "make", "install"
    end
    ENV.prepend_path "PKG_CONFIG_PATH", buildpath/"libcerf/lib/pkgconfig"

    args = %W[
      --disable-dependency-tracking
      --disable-silent-rules
      --prefix=#{prefix}
      --with-readline=#{Formula["readline"].opt_prefix}
      --without-tutorial
    ]

    args << "--disable-wxwidgets" if build.without? "wxmac"
    args << (build.with?("aquaterm") ? "--with-aquaterm" : "--without-aquaterm")
    args << (build.with?("qt") ? "--with-qt" : "--with-qt=no")
    args << (build.with?("x11") ? "--with-x" : "--without-x")

    system "./prepare" if build.head?
    system "./configure", *args
    ENV.deparallelize # or else emacs tries to edit the same file with two threads
    system "make"
    system "make", "install"
  end

  def caveats
    if build.with? "aquaterm"
      <<~EOS
        AquaTerm support will only be built into Gnuplot if the standard AquaTerm
        package from SourceForge has already been installed onto your system.
        If you subsequently remove AquaTerm, you will need to uninstall and then
        reinstall Gnuplot.
      EOS
    end
  end

  test do
    system "#{bin}/gnuplot", "-e", <<~EOS
      set terminal dumb;
      set output "#{testpath}/graph.txt";
      plot sin(x);
    EOS
    assert_predicate testpath/"graph.txt", :exist?
  end
end
