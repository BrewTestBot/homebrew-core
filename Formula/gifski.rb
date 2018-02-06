class Gifski < Formula
  desc "Highest-quality GIF encoder based on pngquant"
  homepage "https://gif.ski/"
  url "https://github.com/ImageOptim/gifski/archive/0.8.0.tar.gz"
  sha256 "f3cab822dd41de17ba4fdc3b8d379b469404573b1a4adcb5f9c9385a7a927760"

  bottle do
    sha256 "1b0508c892d5509e80c9b1851dd0659453a3227638ff3fb2070510248020a819" => :high_sierra
    sha256 "ee8baa305702999090f015ccec6b1e4fc336427834cf6c7e61505c3f56740354" => :sierra
    sha256 "f7d95fd146b488fdd2a3a0a90575edbd5a3623222c4ec50e1b3aa7d453123bef" => :el_capitan
  end

  depends_on "pkg-config" => :build
  depends_on "rust" => :build
  depends_on "ffmpeg"

  def install
    system "cargo", "build", "--release", "--features=video"
    bin.install "target/release/gifski"
  end

  test do
    system bin/"gifski", "-o", "out.gif", test_fixtures("test.png")
    assert_predicate testpath/"out.gif", :exist?
    refute_predicate (testpath/"out.gif").size, :zero?
  end
end
