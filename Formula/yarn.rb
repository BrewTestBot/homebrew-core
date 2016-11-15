require "language/node"

class Yarn < Formula
  desc "Javascript package manager"
  homepage "https://yarnpkg.com/"
  url "https://yarnpkg.com/downloads/0.17.0/yarn-v0.17.0.tar.gz"
  sha256 "bb87332c23baec5680e13c9afa858d851276eca27e33e215a84338fb4acb0026"
  revision 1
  head "https://github.com/yarnpkg/yarn.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "7f6f2621524c87e309fbea9ad7d8f49086dd481358f76f3f57f682ea0f57c2ab" => :sierra
    sha256 "aafe13b85ed27f46f884f38675927f29c4b5ed4fd78e92a3d2c803dcdb743c54" => :el_capitan
    sha256 "bd3f2ece7e38bd73d6090cb478893658515107ca8cee334ba895b030cfaf88f8" => :yosemite
  end

  depends_on "node"

  # https://github.com/yarnpkg/yarn/pull/1840
  patch do
    url "https://gist.githubusercontent.com/ilovezfs/319a920d4de838f1e61f42f08f8b65b5/raw/db81515c9aecaf2a8c7c976797749d4993ba3b07/gistfile1.txt"
    sha256 "3de71734cc04d4c8766423e31f21abd5f206ba1b250f26d6a35ffc7c2ae0022b"
  end

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    (testpath/"package.json").write('{"name": "test"}')
    system bin/"yarn", "add", "jquery"
  end
end
