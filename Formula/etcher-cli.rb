require "language/node"
class EtcherCli < Formula

  desc "Flash OS images to SD cards & USB drives, safely and easily"
  homepage "https://etcher.io/"
  url "https://github.com/resin-io/etcher/archive/v1.4.4.tar.gz",
    :tag => "1.4.4",
    :revision => "434af7b11dd33641231f1b48b8432e68eb472e46"
  head "https://github.com/resin-io/etcher.git"
  sha256 "02082bc1caac746e1cdcd95c2892c9b41ff8d45a672b52f8467548cad4850f5d"
  depends_on 'jq'
  depends_on "node"
  depends_on "python" => :build

  def install
    Language::Node.setup_npm_environment
    ENV.prepend_path "PATH", "#{buildpath}/dist/Etcher-cli-1.4.4-darwin-x64-app/node_modules/.bin/"
    ENV.prepend_path "PATH", prefix/"libexec/node/bin"
    ENV["RELEASE_TYPE"] = "production"
    system "make", "cli-develop"
    system "make", "package-cli"
    bin.install "dist/Etcher-cli-1.4.4-darwin-x64/etcher"
  end

  test do
    system "make", "test-cli"
  end
end
