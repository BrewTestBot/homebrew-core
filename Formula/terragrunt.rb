class Terragrunt < Formula
  desc "Thin wrapper for Terraform e.g. for locking state"
  homepage "https://github.com/gruntwork-io/terragrunt"
  url "https://github.com/gruntwork-io/terragrunt/archive/v0.13.3.tar.gz"
  sha256 "6e5f7c26054b91e0cce0de1deaa204d194bb78a73507d68b9a08b43dc217fe6a"
  head "https://github.com/gruntwork-io/terragrunt.git"

  bottle do
    cellar :any_skip_relocation
    rebuild 1
    sha256 "3a5bad020a8694c9fbf70b0c02a557bc42cb367ea4eb5b3f5e16295f30bde5fa" => :sierra
    sha256 "35fa968f13fd289dca4ecb3a49a7742622a52a0e980c5a5b8a546b607d4d0da0" => :el_capitan
  end

  depends_on "glide" => :build
  depends_on "go" => :build
  depends_on "terraform"

  def install
    ENV["GOPATH"] = buildpath
    ENV["GLIDE_HOME"] = HOMEBREW_CACHE/"glide_home/#{name}"
    mkdir_p buildpath/"src/github.com/gruntwork-io/"
    ln_s buildpath, buildpath/"src/github.com/gruntwork-io/terragrunt"
    system "glide", "install"
    system "go", "build", "-o", bin/"terragrunt", "-ldflags", "-X main.VERSION=v#{version}"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/terragrunt --version")
  end
end
