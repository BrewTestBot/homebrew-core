class Zbar < Formula
  desc "Suite of barcodes-reading tools"
  homepage "http://zbar.sourceforge.net"
  url "https://downloads.sourceforge.net/project/zbar/zbar/0.10/zbar-0.10.tar.bz2"
  sha256 "234efb39dbbe5cef4189cc76f37afbe3cfcfb45ae52493bfe8e191318bdbadc6"
  revision 3

  bottle do
    cellar :any
    sha256 "29d40135e9a56213749341e374d0cf42270d542d1d8a959a7b97b03cea256449" => :sierra
    sha256 "2f77c46a1a74bdd212c9a46c7928ee719f5e2f34fbe4c8ce1cb07e54f670b122" => :el_capitan
    sha256 "531433ae5627a6f6776e9082a68683dd2886e8791b78c738157c3d45f06db051" => :yosemite
  end

  depends_on :x11 => :optional
  depends_on "pkg-config" => :build
  depends_on "jpeg"
  depends_on "imagemagick"
  depends_on "ufraw"
  depends_on "xz"
  depends_on "freetype"
  depends_on "libtool" => :run

  # Fix JPEG handling using patch from
  # https://sourceforge.net/p/zbar/discussion/664596/thread/58b8d79b#8f67
  # already applied upstream but not present in the 0.10 release
  patch :DATA

  def install
    # ImageMagick 7 compatibility
    # Reported 20 Jun 2016 https://sourceforge.net/p/zbar/support-requests/156/
    inreplace ["configure", "zbarimg/zbarimg.c"],
      "wand/MagickWand.h",
      "ImageMagick-7/MagickWand/MagickWand.h"

    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --without-python
      --without-qt
      --disable-video
      --without-gtk
    ]

    if build.with? "x11"
      args << "--with-x"
    else
      args << "--without-x"
    end

    system "./configure", *args
    system "make", "install"
  end

  test do
    system bin/"zbarimg", "-h"
  end
end

__END__
diff --git a/zbar/jpeg.c b/zbar/jpeg.c
index fb566f4..d1c1fb2 100644
--- a/zbar/jpeg.c
+++ b/zbar/jpeg.c
@@ -79,8 +79,15 @@ int fill_input_buffer (j_decompress_ptr cinfo)
 void skip_input_data (j_decompress_ptr cinfo,
                       long num_bytes)
 {
-    cinfo->src->next_input_byte = NULL;
-    cinfo->src->bytes_in_buffer = 0;
+    if (num_bytes > 0) {
+        if (num_bytes < cinfo->src->bytes_in_buffer) {
+            cinfo->src->next_input_byte += num_bytes;
+            cinfo->src->bytes_in_buffer -= num_bytes;
+        }
+        else {
+            fill_input_buffer(cinfo);
+        }
+    }
 }
 
 void term_source (j_decompress_ptr cinfo)
