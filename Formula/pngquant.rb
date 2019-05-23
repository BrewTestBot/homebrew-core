class Pngquant < Formula
  desc "PNG image optimizing utility"
  homepage "https://pngquant.org/"
  url "https://pngquant.org/pngquant-2.12.3-src.tar.gz"
  sha256 "8bb076832a3f1c826393f4be62df8b637dfd6493b13d5839ad697a8a80ccf95b"
  head "https://github.com/kornelski/pngquant.git"

  bottle do
    cellar :any
    sha256 "71656950218e1bc4382a43615f41b02b12539db9b7352e2e423212bec6d7a07e" => :mojave
    sha256 "a71a5b271f72aafce935ebf665afc158b5a1e8d3b62fa916773363dfd43d4ce6" => :high_sierra
    sha256 "898ad660558ca14a04cb465ccf374e24439c6067f428cb665f99486ddb41dcea" => :sierra
  end

  depends_on "pkg-config" => :build
  depends_on "rust" => :build
  depends_on "libpng"
  depends_on "little-cms2"

  def install
    system "cargo", "install", "--root", prefix, "--path", "."
    man1.install "pngquant.1"
  end

  test do
    system "#{bin}/pngquant", test_fixtures("test.png"), "-o", "out.png"
    assert_predicate testpath/"out.png", :exist?
  end
end
