require "language/node"

class Jhipster < Formula
  desc "Generate, develop and deploy Spring Boot + Angular applications"
  homepage "https://jhipster.github.io/"
  url "https://registry.npmjs.org/generator-jhipster/-/generator-jhipster-5.0.0.tgz"
  sha256 "79053caa86ca7439ed9cfd084af17173099ac92d98669a1b10d4b0a5b7c59a86"

  bottle do
    cellar :any_skip_relocation
    sha256 "c2ac85cb4bcfc9bf8a413f6cf6902b17e970c79e461ee679ea79dcf627b5760d" => :high_sierra
    sha256 "6f924ac48b7a4f8a97757246debd22441350cdcea96425ffe8071c6f2b778833" => :sierra
    sha256 "2395390d78628ff651bfe7f8395a02a8487a167343038230732864eebb78eb67" => :el_capitan
  end

  depends_on "node"
  depends_on "yarn"
  depends_on :java => "1.8+"

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    assert_match "execution is complete", shell_output("#{bin}/jhipster info")
  end
end
