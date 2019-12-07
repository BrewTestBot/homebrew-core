class Asciidoc < Formula
  desc "Formatter/translator for text files to numerous formats. Includes a2x"
  homepage "http://asciidoc.org/"
  url "https://github.com/asciidoc/asciidoc-py3/archive/8.6.10.tar.gz"
  sha256 "88911e41d3caf64e1c0363b123612e2ac0ac58c0fb4b7141e9ab67eb3f95fc75"
  revision 3
  head "https://github.com/asciidoc/asciidoc.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "0ae40f0d96d4139362d53ad859639d15e511ce1a3cf56433f7744989824f3d7b" => :catalina
    sha256 "0ae40f0d96d4139362d53ad859639d15e511ce1a3cf56433f7744989824f3d7b" => :mojave
    sha256 "0ae40f0d96d4139362d53ad859639d15e511ce1a3cf56433f7744989824f3d7b" => :high_sierra
  end

  depends_on "autoconf" => :build
  depends_on "docbook-xsl" => :build
  depends_on "docbook"
  depends_on "python"
  depends_on "source-highlight"

  def install
    py3ver = Language::Python.major_minor_version "python3"
    ENV.prepend_path "PATH", Formula["python"].opt_frameworks/"Python.framework/Versions/#{py3ver}/bin"
    ENV["XML_CATALOG_FILES"] = etc/"xml/catalog"

    system "autoconf"
    system "./configure", "--prefix=#{prefix}"

    # otherwise macOS's xmllint bails out
    inreplace "Makefile", "-f manpage", "-f manpage -L"
    system "make", "install"
    system "make", "docs"
  end

  def caveats
    <<~EOS
      If you intend to process AsciiDoc files through an XML stage
      (such as a2x for manpage generation) you need to add something
      like:

        export XML_CATALOG_FILES=#{etc}/xml/catalog

      to your shell rc file so that xmllint can find AsciiDoc's
      catalog files.

      See `man 1 xmllint' for more.
    EOS
  end

  test do
    (testpath/"test.txt").write("== Hello World!")
    system "#{bin}/asciidoc", "-b", "html5", "-o", "test.html", "test.txt"
    assert_match %r{\<h2 id="_hello_world"\>Hello World!\</h2\>}, File.read("test.html")
  end
end
