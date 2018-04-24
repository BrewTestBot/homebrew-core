class Juju < Formula
  desc "DevOps management tool"
  homepage "https://jujucharms.com/"
  url "https://launchpad.net/juju/2.3/2.3.7/+download/juju-core_2.3.7.tar.gz"
  sha256 "0f23ed6a3dc11ec9cd3605ad00e78729a997b5992303aab3e202a59dcbe9e936"

  bottle do
    cellar :any_skip_relocation
    sha256 "a379ce03d2d21c05452dc88d0db35fa8e3a460f3ef0d8efbd4856788bbd289d3" => :high_sierra
    sha256 "e173ed0dcc06e5170caa83d4d9f1c3da7d1a68a802126bec02376b1d2f98b63f" => :sierra
    sha256 "fc3b1f385a4f44aab0e917f6b0bf477fcbc582f68761f99b7fa6435237736a88" => :el_capitan
  end

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    system "go", "build", "github.com/juju/juju/cmd/juju"
    system "go", "build", "github.com/juju/juju/cmd/plugins/juju-metadata"
    bin.install "juju", "juju-metadata"
    bash_completion.install "src/github.com/juju/juju/etc/bash_completion.d/juju"
  end

  test do
    system "#{bin}/juju", "version"
  end
end
