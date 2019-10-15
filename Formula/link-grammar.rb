class LinkGrammar < Formula
  desc "Carnegie Mellon University's link grammar parser"
  homepage "https://www.abisource.com/projects/link-grammar/"
  url "https://www.abisource.com/downloads/link-grammar/5.7.0/link-grammar-5.7.0.tar.gz"
  sha256 "2679921766ca3981d8663338405967df701bfaeeb3f7194219db94990cd9612a"

  bottle do
    sha256 "a6271a6564c1ec4ff95d8223e47385aad3b4df314db579f3e68ea43f9a456870" => :catalina
    sha256 "90b3c98782ea23f109ea0046548c531331f3d07e9645a4d9bd01ae43381c01a0" => :mojave
    sha256 "f201950217bc053f94351992075900a0d6f6d96a22d5411df6ee54e007838762" => :high_sierra
    sha256 "e4103b4f47f143886f2bbfaa089a318921ffb297fedfa0174d0403334375d732" => :sierra
  end

  depends_on "ant" => :build
  depends_on "autoconf" => :build
  depends_on "autoconf-archive" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build

  def install
    ENV["PYTHON_LIBS"] = "-undefined dynamic_lookup"
    inreplace "bindings/python/Makefile.am",
      "$(PYTHON2_LDFLAGS) -module -no-undefined",
      "$(PYTHON2_LDFLAGS) -module"
    inreplace "bindings/java/build.xml.in",
      "<property name=\"source\" value=\"1.6\"/>",
      "<property name=\"source\" value=\"1.7\"/>"
    inreplace "bindings/java/build.xml.in",
      "<property name=\"target\" value=\"1.6\"/>",
      "<property name=\"target\" value=\"1.7\"/>"
    system "autoreconf", "-fiv"
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "#{bin}/link-parser", "--version"
  end
end
