require "nokogiri"

class Latex2html < Formula
  desc "LaTeX-to-HTML translator"
  homepage "https://www.ctan.org/pkg/latex2html"
  url "http://mirrors.ctan.org/support/latex2html/latex2html-2016.tar.gz"
  sha256 "ab1dbc18ab0ec62f65c1f8c14f2b74823a0a2fc54b07d73ca49524bcae071309"

  bottle do
    cellar :any_skip_relocation
    sha256 "96aba432faa475b5201a84d032e5e4e90d95264e23387ba20bd59fea5d06403b" => :sierra
    sha256 "093a49aaa3b77c884b9e7aa7ebcff872dc763a984c779fa03b3a50013c311ea1" => :el_capitan
    sha256 "6a304d1b869c3bdb472c4eea5b4251e626a89446c3d55443da81bbbbe626a59c" => :yosemite
  end

  depends_on "netpbm"
  depends_on "ghostscript"

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--without-mktexlsr",
                          "--with-texpath=#{share}/texmf/tex/latex/html"
    system "make", "install"
  end

  test do
    # Trivial Tests
    assert_match version.to_s, shell_output("#{bin}/latex2html --version")
    system "#{bin}/latex2html", "--help"

    # Non-Trivial Test
    test_file = File.new(testpath/"test.tex", "w")
    contents_of_file = '
      \documentclass{article}
      \usepackage[utf8]{inputenc}

      \title{Experimental Setup}
      \date{November 2016}

      \usepackage{natbib}
      \usepackage{graphicx}

      \begin{document}

      \maketitle

      \section{Experimental Setup}
        \textbf{it works!}
      \end{document}
    '
    test_file.puts(contents_of_file)
    test_file.close

    system "#{bin}/latex2html", "test.tex"

    # Check if the 'section' links exist in the main html file
    main_html_file = File.read("test/test.html")
    assert_match /Experimental Setup/, main_html_file
    # Now, goes to that html file and checks the content
    document = Nokogiri::HTML(main_html_file)
    next_file_link = document.at('a:contains("Experimental Setup")')["href"]
    assert_match /it works!/, File.read("test/#{next_file_link}")
  end
end
