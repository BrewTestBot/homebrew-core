class Anjuta < Formula
  desc "GNOME Integrated Development Environment"
  homepage "http://anjuta.org"
  url "https://download.gnome.org/sources/anjuta/3.22/anjuta-3.22.0.tar.xz"
  sha256 "4face1c063a5a6687a6cfc6f1f700ba15f13664633c05caa2fbf50317608dd03"
  revision 1

  bottle do
    rebuild 1
    sha256 "967289110b7f4674d36c5f20cb593486444b1d5378cb5f50e00d44201ae377d3" => :sierra
    sha256 "5353434211919f66c39b97b74f85e484c6a2389f0ce815d94a441bc05e4a169c" => :el_capitan
    sha256 "ab8f2029e695fb7dc1f2ce8bea54024ba44287cb2da50348f737a645fac55778" => :yosemite
  end

  depends_on :python if MacOS.version <= :snow_leopard
  depends_on "pkg-config" => :build
  depends_on "intltool" => :build
  depends_on "itstool" => :build
  depends_on "gtksourceview3"
  depends_on "libxml2" => "with-python"
  depends_on "libgda"
  depends_on "gdl"
  depends_on "vte3"
  depends_on "hicolor-icon-theme"
  depends_on "gnome-icon-theme"
  depends_on "gnutls"
  depends_on "shared-mime-info"
  depends_on "vala" => :recommended
  depends_on "autogen" => :recommended
  depends_on "gnome-themes-standard" => :optional

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--disable-schemas-compile"
    ENV.append_path "PYTHONPATH", "#{Formula["libxml2"].opt_lib}/python2.7/site-packages"
    system "make", "install"
  end

  def post_install
    system "#{Formula["glib"].opt_bin}/glib-compile-schemas", "#{HOMEBREW_PREFIX}/share/glib-2.0/schemas"
    system "#{Formula["gtk+3"].opt_bin}/gtk3-update-icon-cache", "-f", "-t", "#{HOMEBREW_PREFIX}/share/icons/hicolor"
    # HighContrast is provided by gnome-themes-standard
    if File.file?("#{HOMEBREW_PREFIX}/share/icons/HighContrast/.icon-theme.cache")
      system "#{Formula["gtk+3"].opt_bin}/gtk3-update-icon-cache", "-f", "-t", "#{HOMEBREW_PREFIX}/share/icons/HighContrast"
    end
    system "#{Formula["shared-mime-info"].opt_bin}/update-mime-database", "#{HOMEBREW_PREFIX}/share/mime"
  end

  test do
    system "#{bin}/anjuta", "--version"
  end
end
