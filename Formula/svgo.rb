require "language/node"

class Svgo < Formula
  desc "Nodejs-based tool for optimizing SVG vector graphics files"
  homepage "https://github.com/svg/svgo"
  url "https://github.com/svg/svgo/archive/v1.2.2.tar.gz"
  sha256 "df4ed786a2f4f4b7659df9e6989f6d2c7ccf1647848bd0051b3b0f4d028a0064"

  bottle do
    cellar :any_skip_relocation
    sha256 "225c5919dc3bfd29c08f86863878c283ad3d647b706b3d495b1484cd16e33850" => :mojave
    sha256 "13b0ac5a9ae8019bee8ff955c22d5872bda3c843ef0b7b68897a0e5606956112" => :high_sierra
    sha256 "93e01c8e34b2a467a35e74f8ae40374cf6e38466717fff0f8339b637d9172ea3" => :sierra
  end

  depends_on "node"

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    cp test_fixtures("test.svg"), testpath
    system bin/"svgo", "test.svg", "-o", "test.min.svg"
    assert_match /^<svg /, (testpath/"test.min.svg").read
  end
end
