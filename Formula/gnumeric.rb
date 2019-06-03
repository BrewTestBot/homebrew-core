class Gnumeric < Formula
  desc "GNOME Spreadsheet Application"
  homepage "https://projects.gnome.org/gnumeric/"
  url "https://download.gnome.org/sources/gnumeric/1.12/gnumeric-1.12.45.tar.xz"
  sha256 "3098ada0a24effbde52b0074968a8dc03b7cf1c522e9e1b1186f48bb67a00d31"

  bottle do
    sha256 "c4abaf0d2aefc0019c9904f07e78fb368df1c1f77c29f72d0aa2328f4644fe04" => :mojave
    sha256 "898b856734071c0241019c21f586aceecc96ecdc902352921e87f869b8dd39b8" => :high_sierra
    sha256 "55b1f0fdb7bf24d000ff6aa87dcf023a14bb8d2eff6452fd9a607eaf2edd81d2" => :sierra
  end

  depends_on "intltool" => :build
  depends_on "pkg-config" => :build
  depends_on "adwaita-icon-theme"
  depends_on "gettext"
  depends_on "goffice"
  depends_on "itstool"
  depends_on "libxml2"
  depends_on "rarian"

  def install
    # ensures that the files remain within the keg
    inreplace "component/Makefile.in",
              "GOFFICE_PLUGINS_DIR = @GOFFICE_PLUGINS_DIR@",
              "GOFFICE_PLUGINS_DIR = @libdir@/goffice/@GOFFICE_API_VER@/plugins/gnumeric"

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--disable-schemas-compile"
    system "make", "install"
  end

  def post_install
    system "#{Formula["glib"].opt_bin}/glib-compile-schemas", "#{HOMEBREW_PREFIX}/share/glib-2.0/schemas"
  end

  test do
    system bin/"gnumeric", "--version"
  end
end
