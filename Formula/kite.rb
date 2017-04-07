class Kite < Formula
  desc "Programming language designed to minimize programmer experience"
  homepage "http://www.kite-language.org/"
  url "http://www.kite-language.org/files/kite-1.0.4.tar.gz"
  sha256 "8f97e777c3ea8cb22fa1236758df3c479bba98be3deb4483ae9aff4cd39c01d5"

  bottle do
    rebuild 1
    sha256 "256735ee408c98fe6bd6a9f9f351047f9f60a514cba1b871b39b5696f291d338" => :sierra
    sha256 "9127297a0c289c0fed8c6c8735f5a1b3291707a4cd8ba003d07acbdf000f4e4a" => :el_capitan
    sha256 "943ae3e223080a4f64c3e1c2b0278fb0ca70100337f1e5db54b772aa45b50962" => :yosemite
  end

  depends_on "bdw-gc"

  # patch to build against bdw-gc 7.2, sent upstream
  patch :DATA

  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    output = pipe_output("#{bin}/kite", "'hello, world'|print;", 0)
    assert_equal "hello, world", output.chomp
  end
end

__END__
--- a/backend/common/kite_vm.c	2010-08-21 01:20:25.000000000 +0200
+++ b/backend/common/kite_vm.c	2012-02-11 02:29:37.000000000 +0100
@@ -152,7 +152,12 @@
 #endif
 
 #ifdef HAVE_GC_H
+#if GC_VERSION_MAJOR >= 7 && GC_VERSION_MINOR >= 2
+    ret->old_proc = GC_get_warn_proc();
+    GC_set_warn_proc ((GC_warn_proc)kite_ignore_gc_warnings);
+#else
     ret->old_proc = GC_set_warn_proc((GC_warn_proc)kite_ignore_gc_warnings);
+#endif
 #endif /* HAVE_GC_H */
 
     return ret;
