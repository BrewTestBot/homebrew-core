class Dfmt < Formula
  desc "Formatter for D source code"
  homepage "https://github.com/dlang-community/dfmt"
  url "https://github.com/dlang-community/dfmt.git",
      :tag => "v0.5.0",
      :revision => "fef85e388a41add75020675ab33ed7e55c3efe85"

  head "https://github.com/dlang-community/dfmt.git", :shallow => false

  bottle do
    sha256 "94174f2b10198e8a58f548d0f55d67bf9660c07eee15ef7c89a5a874ad107649" => :sierra
    sha256 "ebbad70fca15ca4dfe2ed7f2b790b6994e34ff460d74dc44da78c8fe2a7235d4" => :el_capitan
    sha256 "b8de4e3f4f490c157deecfaa36db786de0ad3b040d7172a88e176d6bfb377c06" => :yosemite
    sha256 "cf0880574305df3859312cb927aa6a72d1041694677eb5305e64152416c34a8a" => :mavericks
  end

  depends_on "dmd" => :build

  def install
    system "make"
    bin.install "bin/dfmt"
  end

  test do
    (testpath/"test.d").write <<-EOS.undent
    import std.stdio; void main() { writeln("Hello, world without explicit compilations!"); }
    EOS

    expected = <<-EOS.undent
    import std.stdio;

    void main()
    {
        writeln("Hello, world without explicit compilations!");
    }
    EOS

    system "#{bin}/dfmt", "-i", "test.d"

    assert_equal expected, (testpath/"test.d").read
  end
end
