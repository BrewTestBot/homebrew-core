class Annie < Formula
  desc "Fast, simple and clean video downloader"
  homepage "https://github.com/iawia002/annie"
  url "https://github.com/iawia002/annie/archive/0.7.3.tar.gz"
  sha256 "98f00e5b6db971a55fa38512f93c4dec26599ef26a16e08cdaa5a0ad65e32bd0"

  bottle do
    cellar :any_skip_relocation
    sha256 "c5f2ce2e290b2400bc465bb6a444eb26ffb7db86b096613311283e75c9cf646e" => :high_sierra
    sha256 "e3fb0a4a96a3bc783a9aefadfaedbfc3d02bb920e57d88992e778c695c6c9fdd" => :sierra
    sha256 "17715faa51be55f83f66aaec8560ab7d462ff5e60e66fc9d164e572c330bafa7" => :el_capitan
  end

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    (buildpath/"src/github.com/iawia002/annie").install buildpath.children
    cd "src/github.com/iawia002/annie" do
      system "go", "build", "-o", bin/"annie"
      prefix.install_metafiles
    end
  end

  test do
    system bin/"annie", "-i", "https://www.bilibili.com/video/av20203945"
  end
end
