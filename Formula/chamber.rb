class Chamber < Formula
  desc "CLI for managing secrets through AWS SSM Parameter Store"
  homepage "https://github.com/segmentio/chamber"
  url "https://github.com/segmentio/chamber/archive/v2.2.0.tar.gz"
  sha256 "5f6830e93b55c4043fba819518eeaca51990480bcec024b306be58fb99d083bd"
  head "https://github.com/segmentio/chamber.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "049834dba6d904db515db1675a613a7545646d2ebb3df21eb7c6c4c05c3ee2e9" => :mojave
    sha256 "1eaa1dd2acde6d889557b0f713c7ec9655cb8715f5526f50bfe7c63b9ce63d3c" => :high_sierra
    sha256 "413cbf130fbd5bef2c69f74eb9ec2bf077ce1aa90a935d825cc55e0c88b983c3" => :sierra
    sha256 "a44294004e2aaf3bd9514edf0ba7bddeff1e10b198722c9d69cff7f0244cd9c5" => :el_capitan
  end

  depends_on "go" => :build
  depends_on "govendor" => :build

  def install
    ENV["GOPATH"] = buildpath
    ENV["GOOS"] = "darwin"
    ENV["GOARCH"] = "amd64"
    ENV["CGO_ENABLED"] = "0"

    path = buildpath/"src/github.com/segmentio/chamber"
    path.install Dir["{*,.git}"]

    cd "src/github.com/segmentio/chamber" do
      system "govendor", "sync"
      system "go", "build", "-o", bin/"chamber",
                   "-ldflags", "-X main.Version=#{version}"
      prefix.install_metafiles
    end
  end

  test do
    ENV.delete "AWS_REGION"
    output = shell_output("#{bin}/chamber list service 2>&1", 1)
    assert_match "MissingRegion", output

    ENV["AWS_REGION"] = "us-west-2"
    output = shell_output("#{bin}/chamber list service 2>&1", 1)
    assert_match "NoCredentialProviders", output
  end
end
