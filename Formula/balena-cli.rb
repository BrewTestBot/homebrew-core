require "language/node"

class BalenaCli < Formula
  desc "The official balena CLI tool"
  homepage "https://www.balena.io/docs/reference/cli/"
  # Frequent upstream releases, do not update more than once a week
  url "https://registry.npmjs.org/balena-cli/-/balena-cli-11.17.2.tgz"
  sha256 "8c151fcd8f3182cb399752736c24d289c9f41defa8e92c57bf04d0fba39ba774"

  bottle do
    sha256 "d1b17a230b2bed6c0b958f4317b3b79e01a977a2afc843475dcdd943e77a4e3e" => :catalina
    sha256 "7b5fd7bdff4eaf65694a8ba25a9360d5d6746af196eab146f4636cd1d4a076ea" => :mojave
  end

  depends_on "node"

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    output = shell_output("#{bin}/balena login --credentials --email johndoe@gmail.com --password secret 2>/dev/null", 1)
    assert_match "Logging in to balena-cloud.com", output
  end
end
