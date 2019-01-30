require "language/node"

class Fx < Formula
  desc "Command-line JSON processing tool"
  homepage "https://github.com/antonmedv/fx"
  url "https://registry.npmjs.org/fx/-/fx-11.0.0.tgz"
  sha256 "9a76aa26525bf68eae81b1d9530daabd7a952f4d32fd0124fcdd30e2d6c3145f"

  bottle do
    cellar :any_skip_relocation
    sha256 "61e5b0de22f359cef3749778841839d46ac96f3cc1fc91440d5df4d65c12a08c" => :mojave
    sha256 "bfb09f2064c3114a22e41299a002253ef28f4d6caedb2aba87eb3c75bac4b40f" => :high_sierra
    sha256 "e2bcc77955807bebb57a9a839d7566b54bdcfc05c6a3758601e0f6b2be927993" => :sierra
  end

  depends_on "node"

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    assert_match "bar", shell_output("echo '{\"foo\": \"bar\"}' #{bin}/fx .foo")
  end
end
