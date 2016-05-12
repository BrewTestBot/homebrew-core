class FileRoller < Formula
  desc "GNOME archive manager"
  homepage "https://wiki.gnome.org/Apps/FileRoller"
  url "https://download.gnome.org/sources/file-roller/3.16/file-roller-3.16.4.tar.xz"
  sha256 "5455980b2c9c7eb063d2d65560ae7ab2e7f01b208ea3947e151680231c7a4185"

  bottle do
    revision 2
    sha256 "70623f6946a4d5fc4919e9203c39e81ce1127d1a1bff8acfccffdf09e8ad4e7a" => :el_capitan
    sha256 "ba96381a0829633994360266961205d3f6d968b5b6a29657121ee5e6bff6470a" => :yosemite
    sha256 "8db9ae24a3d4d8fc8577a36a52833a5ad12371bd967d3f6ed643d21924f82e5d" => :mavericks
  end

  depends_on "pkg-config" => :build
  depends_on "intltool" => :build
  depends_on "itstool" => :build
  depends_on "libxml2" => ["with-python", :build]
  depends_on "gtk+3"
  depends_on "json-glib"
  depends_on "libmagic"
  depends_on "libarchive"
  depends_on "hicolor-icon-theme"
  depends_on "gnome-icon-theme"

  # Add linked-library dependencies
  depends_on "atk"
  depends_on "cairo"
  depends_on "gdk-pixbuf"
  depends_on "gettext"
  depends_on "glib"
  depends_on "pango"

  # These can be removed when the next version (>3.16.4) is released, since they
  # are only required to support the patch below, which will no longer be needed
  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "yelp-tools" => :build

  # Remove when >3.16.4 is released
  # Build fails during schema validation when using glib >= 1.45.1
  # Upstream patch for https://bugzilla.gnome.org/show_bug.cgi?id=756607
  patch do
    url "https://git.gnome.org/browse/file-roller/patch/?id=37df6d640817127dbad0f9ba94141cfb1e6a8360"
    sha256 "5dee926832a607fc703518cd35b8fe0846c6bf760faf19982a89fe5f5c21fe75"
  end

  def install
    ENV.append "CFLAGS", "-I#{Formula["libmagic"].opt_include}"
    ENV.append "LIBS", "-L#{Formula["libmagic"].opt_lib}"

    # Remove when >3.16.4 is released
    system "autoreconf", "-fiv"

    # forces use of gtk3-update-icon-cache instead of gtk-update-icon-cache. No bugreport should
    # be filed for this since it only occurs because Homebrew renames gtk+3's gtk-update-icon-cache
    # to gtk3-update-icon-cache in order to avoid a collision between gtk+ and gtk+3.
    inreplace "data/Makefile.in", "gtk-update-icon-cache", "gtk3-update-icon-cache"

    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--disable-schemas-compile",
                          "--disable-packagekit",
                          "--enable-magic"
    ENV.append_path "PYTHONPATH", "#{Formula["libxml2"].opt_lib}/python2.7/site-packages"
    system "make", "install"
  end

  def post_install
    system "#{Formula["glib"].opt_bin}/glib-compile-schemas", "#{HOMEBREW_PREFIX}/share/glib-2.0/schemas"
    system "#{Formula["gtk+3"].opt_bin}/gtk3-update-icon-cache", "-f", "-t", "#{HOMEBREW_PREFIX}/share/icons/hicolor"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/file-roller --version 2>&1")
  end
end
