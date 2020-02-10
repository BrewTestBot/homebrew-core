class Libgee < Formula
  desc "Collection library providing GObject-based interfaces"
  homepage "https://wiki.gnome.org/Projects/Libgee"
  url "https://download.gnome.org/sources/libgee/0.20/libgee-0.20.3.tar.xz"
  sha256 "d0b5edefc88cbca5f1709d19fa62aef490922c6577a14ac4e7b085507911a5de"

  bottle do
    cellar :any
    sha256 "b5d20d4f3591375eaa2fb57d674fabd1cb80b49734c496699e929491ea46150d" => :catalina
    sha256 "b8b7c79e89685fb854f34499d2d8663086ae4f84e5ecbe25cf48cab032a7369f" => :mojave
    sha256 "6009ce0ec8b746b392cca3eb0e1fd988a3f24d2c54e0daa496ab55c108449f83" => :high_sierra
    sha256 "2347366d694bda8b72b074b396f3be1bbd443e7190d40a870df3856e017b578f" => :sierra
  end

  depends_on "gobject-introspection" => :build
  depends_on "pkg-config" => :build
  depends_on "vala" => :build
  depends_on "glib"

  def install
    # ensures that the gobject-introspection files remain within the keg
    inreplace "gee/Makefile.in" do |s|
      s.gsub! "@HAVE_INTROSPECTION_TRUE@girdir = @INTROSPECTION_GIRDIR@",
              "@HAVE_INTROSPECTION_TRUE@girdir = $(datadir)/gir-1.0"
      s.gsub! "@HAVE_INTROSPECTION_TRUE@typelibdir = @INTROSPECTION_TYPELIBDIR@",
              "@HAVE_INTROSPECTION_TRUE@typelibdir = $(libdir)/girepository-1.0"
    end

    system "./configure", "--prefix=#{prefix}",
                          "--disable-dependency-tracking"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <gee.h>

      int main(int argc, char *argv[]) {
        GType type = gee_traversable_stream_get_type();
        return 0;
      }
    EOS
    gettext = Formula["gettext"]
    glib = Formula["glib"]
    flags = %W[
      -I#{gettext.opt_include}
      -I#{glib.opt_include}/glib-2.0
      -I#{glib.opt_lib}/glib-2.0/include
      -I#{include}/gee-0.8
      -L#{gettext.opt_lib}
      -L#{glib.opt_lib}
      -L#{lib}
      -lgee-0.8
      -lglib-2.0
      -lgobject-2.0
      -lintl
    ]
    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test"
  end
end
