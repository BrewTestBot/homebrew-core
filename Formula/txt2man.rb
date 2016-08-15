class Txt2man < Formula
  desc "Convert flat ASCII text to man page format"
  homepage "https://github.com/mvertes/txt2man"
  url "https://github.com/mvertes/txt2man/archive/txt2man-1.6.0.tar.gz"
  sha256 "f6939e333a12e1ecceccaa547b58f4bf901a580cd2d8f822f8c292934c920c99"
  head "https://github.com/mvertes/txt2man.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "b21b275a37f0f8fd3623e3c5590326737f448f9cc2dd9f24556021d2326fef6c" => :el_capitan
    sha256 "d3831605b2d3c5b40dcc9f9a24ab875015c399da283b09f4de61161752b7e590" => :yosemite
    sha256 "b456aee5d116f56b8c0792f904f1c44b437d8ded3a3fa0409fa12ca897020233" => :mavericks
  end

  depends_on "gawk"
  depends_on "coreutils"

  def install
    ENV.prepend_path "PATH", Formula["coreutils"].opt_libexec/"gnubin"
    system "make", "install", "prefix=#{prefix}"
    bin.env_script_all_files(libexec/"bin", :PATH => "#{HOMEBREW_PREFIX}/opt/coreutils/libexec/gnubin:$PATH")
  end

  test do
    # txt2man
    (testpath/"test.txt").write <<-EOS.undent
      A TITLE

      blah blah blah
    EOS

    assert_match(/\.SH A TITLE/, shell_output("#{bin}/txt2man test.txt"))

    # src2man
    (testpath/"test.c").write <<-EOS.undent
      #include <stdio.h>

      /** 3
      * main - do stuff
      **/
      int main(void) { return 0; }
    EOS

    assert_equal "main.3\n", shell_output("#{bin}/src2man test.c 2>&1")
    assert_match(/\\fBmain\ \\fP\-\ do\ stuff\n/, File.read("main.3").lines.to_a[4])

    # bookman
    system "#{bin}/bookman", "-t", "Test", "-o", "test", *Dir["#{man1}/*"]
    assert File.exist?("test")
  end
end
