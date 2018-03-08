class Shfmt < Formula
  desc "Autoformat shell script source code"
  homepage "https://github.com/mvdan/sh"
  url "https://github.com/mvdan/sh/archive/v2.3.0.tar.gz"
  sha256 "7fac5b1d054f39f68440b19752321a59f41085b767311bd978cdcb107730ff8e"
  head "https://github.com/mvdan/sh.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "b4f156c06af9cfd3e7594c34c89de0b3951f3dacf02e2df6cc53f3fab0d06297" => :high_sierra
    sha256 "11dc2e4c80839e8b70ae53361ddff8f0073e1318bf03886213a6fb56dd556466" => :sierra
    sha256 "e6b3f6986382c203287e6bc0bf32ddf839031704869d95aa88adfadeaa4b7bef" => :el_capitan
  end

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    (buildpath/"src/mvdan.cc").mkpath
    ln_sf buildpath, buildpath/"src/mvdan.cc/sh"
    system "go", "build", "-a", "-tags", "production brew", "-o", "#{bin}/shfmt", "mvdan.cc/sh/cmd/shfmt"
  end

  test do
    (testpath/"test").write "\t\techo foo"
    system "#{bin}/shfmt", testpath/"test"
  end
end
