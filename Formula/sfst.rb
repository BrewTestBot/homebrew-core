class Sfst < Formula
  desc "Toolbox for morphological analysers and other FST-based tools"
  homepage "https://www.cis.uni-muenchen.de/~schmid/tools/SFST/"
  url "https://www.cis.uni-muenchen.de/~schmid/tools/SFST/data/SFST-1.4.7e.tar.gz"
  sha256 "9e1bda84db1575ffb3bea56f3d49898661ad663280c5b813467cd17a7d6b76ac"

  bottle do
    cellar :any_skip_relocation
    sha256 "2896c595e911f263874ef30e7d615fac1bd3fe332f14c18bdf042addc0619155" => :catalina
    sha256 "74aa99f751d850a1fcdc1cf347406e7137625cdc8010e3dacce972858a5469f7" => :mojave
    sha256 "6c5e1bc0f6e6d78a565b7892767035238957ab80b838b496a039a9174475056f" => :high_sierra
    sha256 "b3c2889ed84c29e3fb4a2d0f89af99631045178ea30227c8b6ffd3f8cdf308d1" => :sierra
    sha256 "96b01f2f7ddfe59b2d0d924d456e5bbd3b2b1ab9b0c909da98a4773a61f63e69" => :el_capitan
  end

  def install
    cd "src" do
      system "make"
      system "make", "DESTDIR=#{prefix}/", "install"
      system "make", "DESTDIR=#{share}/", "maninstall"
    end
  end

  test do
    require "open3"

    (testpath/"foo.fst").write "Hello"
    system "#{bin}/fst-compiler", "foo.fst", "foo.a"
    assert_predicate testpath/"foo.a", :exist?, "Foo.a should exist but does not!"

    Open3.popen3("#{bin}/fst-mor", "foo.a") do |stdin, stdout, _|
      stdin.write("Hello")
      stdin.close
      expected_output = "reading transducer...\nfinished.\nHello\n"
      actual_output = stdout.read
      assert_equal expected_output, actual_output
    end
  end
end
