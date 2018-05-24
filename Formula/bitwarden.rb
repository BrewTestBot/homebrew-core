require "language/node"

class Bitwarden < Formula
  desc "Secure and free password manager for all of your devices"
  homepage "https://bitwarden.com/"
  url "https://registry.npmjs.org/@bitwarden/cli/-/cli-1.0.0.tgz"
  sha256 "75475a7eb9c728b0b16c1a69d397391019617cfbf73304bcc8724d9fd32aec47"

  depends_on "node"

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    assert_equal "1.0.0\n", shell_output("#{bin}/bw -v")
  end
end
