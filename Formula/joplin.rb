require "language/node"

class Joplin < Formula
  desc "Note taking and to-do application with synchronisation capabilities"
  homepage "http://joplin.cozic.net/"
  url "https://registry.npmjs.org/joplin/-/joplin-0.10.87.tgz"
  sha256 "65d392205d83172f11dee2f874f36292771878e37a0c6633d0c8d2b45f7ba093"

  bottle do
    sha256 "35a0655ce2901f564c97eb30fb4b6fcd8c691ee50c05fb4da3f764f1823ada93" => :high_sierra
    sha256 "e4611d571e93f77fb6eaaa5ef3353a92d1d0c3dc8db0252a8f81acf672db51a9" => :sierra
    sha256 "67e38843070c87964fefef86f00b2163a809b91b1970a531fdca7edbb7fbb45d" => :el_capitan
  end

  depends_on "node"
  depends_on "python" => :build if MacOS.version <= :snow_leopard

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    system bin/"joplin", "config", "editor", "subl"
    assert_match "editor = subl", shell_output("#{bin}/joplin config")
  end
end
