class Gucharmap < Formula
  desc "GNOME Character Map, based on the Unicode Character Database"
  homepage "https://live.gnome.org/Gucharmap"
  url "https://download.gnome.org/sources/gucharmap/9.0/gucharmap-9.0.0.tar.xz"
  sha256 "d698ce4bba5486f7e32e9a4ec0ecd916926fb876640856746121d8ae8012765c"

  bottle do
    sha256 "7cd1aab34bc2297b50b5310fd51fe833ae812d25055bf249606ffd05b5c923a9" => :el_capitan
    sha256 "0a216f345c3ddf891d44afbbffb438592b96ad772ae069bcbfa53f878c349cdd" => :yosemite
    sha256 "d25ad62351fd286c8523940c5826081a8af9cb0cb3946028978a6fc389e5799a" => :mavericks
  end

  depends_on "pkg-config" => :build
  depends_on "intltool" => :build
  depends_on "itstool" => :build
  depends_on "desktop-file-utils" => :build
  depends_on "wget" => :build
  depends_on "coreutils" => :build
  depends_on "gtk+3"

  def install
    ENV.append_path "PYTHONPATH", "#{Formula["libxml2"].opt_lib}/python2.7/site-packages"
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--disable-Bsymbolic",
                          "--disable-schemas-compile",
                          "--enable-introspection=no"
    system "make"
    system "make", "install"
  end

  def post_install
    system "#{Formula["glib"].opt_bin}/glib-compile-schemas", "#{HOMEBREW_PREFIX}/share/glib-2.0/schemas"
  end

  test do
    system "#{bin}/gucharmap", "--version"
  end
end
