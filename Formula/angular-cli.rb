require "language/node"

class AngularCli < Formula
  desc "CLI tool for Angular"
  homepage "https://cli.angular.io/"
  url "https://registry.npmjs.org/@angular/cli/-/cli-6.1.4.tgz"
  sha256 "3d07424c9513123fcefa7fc8dd3b1af3eec25093182216ebec490393d5cf7f37"

  bottle do
    sha256 "395b462edfa09e655ef98ff37986ffd8a382cfa81c4a1fc354d9f26835089611" => :high_sierra
    sha256 "03bcd0172897710a0bdd30aada3920530487376619ee737bfa3f7ee062a34189" => :sierra
    sha256 "5c1cecc7b4dfd87b2b118a104ead7f7bd185dd4d6b5a49abc7c47c05d5339ff3" => :el_capitan
  end

  depends_on "node"

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    system bin/"ng", "new", "angular-homebrew-test", "--skip-install"
    assert_predicate testpath/"angular-homebrew-test/package.json", :exist?, "Project was not created"
  end
end
