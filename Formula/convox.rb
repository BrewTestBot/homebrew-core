class Convox < Formula
  desc "Command-line interface for the Rack PaaS on AWS"
  homepage "https://convox.com/"
  url "https://github.com/convox/rack/archive/20190115161630.tar.gz"
  sha256 "9647b1bc1bdadeefe4d086209f69189de002d3130f6df7741f48b51e3c8679a1"

  bottle do
    cellar :any_skip_relocation
    sha256 "b7e3ac63e24ce3118aa60c27be8114324600a316f9b02fd9aec6480fac513492" => :mojave
    sha256 "064a3777d6151c43a9a23594c084132d965e77722c0b69dac79862917f311f08" => :high_sierra
    sha256 "8c30cb8a07dd581090ddc667feb813a77ba15b77e8f1e57d93d4275b2e3907f2" => :sierra
  end

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    (buildpath/"src/github.com/convox/rack").install Dir["*"]
    system "go", "build", "-ldflags=-X main.version=#{version}",
           "-o", bin/"convox", "-v", "github.com/convox/rack/cmd/convox"
    prefix.install_metafiles
  end

  test do
    system bin/"convox"
  end
end
