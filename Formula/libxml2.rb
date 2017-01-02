class Libxml2 < Formula
  desc "GNOME XML library"
  homepage "http://xmlsoft.org"
  revision 1

  stable do
    url "http://xmlsoft.org/sources/libxml2-2.9.4.tar.gz"
    mirror "ftp://xmlsoft.org/libxml2/libxml2-2.9.4.tar.gz"
    sha256 "ffb911191e509b966deb55de705387f14156e1a56b21824357cdf0053233633c"

    # All patches upstream already. Remove whenever 2.9.5 is released.
    # Fixes CVE-2016-4658, CVE-2016-5131.
    patch do
      url "https://mirrors.ocf.berkeley.edu/debian/pool/main/libx/libxml2/libxml2_2.9.4+dfsg1-2.1.debian.tar.xz"
      mirror "https://mirrorservice.org/sites/ftp.debian.org/debian/pool/main/libx/libxml2/libxml2_2.9.4+dfsg1-2.1.debian.tar.xz"
      sha256 "e71790a415e5d6b4a6490040d946d584fa79465571da3b186cc67b8f064cd104"
      apply "patches/0003-Fix-NULL-pointer-deref-in-XPointer-range-to.patch",
            "patches/0004-Fix-comparison-with-root-node-in-xmlXPathCmpNodes.patch",
            "patches/0005-Fix-XPointer-paths-beginning-with-range-to.patch",
            "patches/0006-Disallow-namespace-nodes-in-XPointer-ranges.patch",
            "patches/0007-Fix-more-NULL-pointer-derefs-in-xpointer.c.patch"
    end
  end

  bottle do
    cellar :any
    sha256 "48fa14c9f84184afd4623aa414589b1ea1088e422d4fd326c82dbe2025ed64f8" => :sierra
    sha256 "106885b0ac96d1f59c5a1f7588ffc938d90361fb9e68cbdd74db2177ea3fa694" => :el_capitan
    sha256 "abc9899e778ff2d5abcdac5c1b8b976b9811029b739d557c1ac61dbe1ef2cc19" => :yosemite
    sha256 "03f73fbc3f99f098f44ff5805aadd1b5cd6c4741e9ca9f6e66d9cc4a9b2f1a5a" => :mavericks
  end

  head do
    url "https://git.gnome.org/browse/libxml2.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  keg_only :provided_by_osx

  option :universal

  depends_on :python => :optional

  def install
    ENV.universal_binary if build.universal?
    if build.head?
      inreplace "autogen.sh", "libtoolize", "glibtoolize"
      system "./autogen.sh"
    end

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--without-python",
                          "--without-lzma"
    system "make"
    ENV.deparallelize
    system "make", "install"

    if build.with? "python"
      cd "python" do
        # We need to insert our include dir first
        inreplace "setup.py", "includes_dir = [", "includes_dir = ['#{include}', '#{MacOS.sdk_path}/usr/include',"
        system "python", "setup.py", "install", "--prefix=#{prefix}"
      end
    end
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <libxml/tree.h>

      int main()
      {
        xmlDocPtr doc = xmlNewDoc(BAD_CAST "1.0");
        xmlNodePtr root_node = xmlNewNode(NULL, BAD_CAST "root");
        xmlDocSetRootElement(doc, root_node);
        xmlFreeDoc(doc);
        return 0;
      }
    EOS
    args = shell_output("#{bin}/xml2-config --cflags --libs").split
    args += %w[test.c -o test]
    system ENV.cc, *args
    system "./test"
  end
end
