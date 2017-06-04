class Lxc < Formula
  desc "CLI client for interacting with LXD"
  homepage "https://linuxcontainers.org"
  url "https://linuxcontainers.org/downloads/lxd/lxd-2.14.tar.gz"
  sha256 "dbb8fcdc1944c35008c517d0cee3bc07bde8ed3e01e81ad41a6bf46ba13ed674"

  bottle do
    cellar :any_skip_relocation
    sha256 "112ad7bca8c1dfb2c4c9a369334b46a2cb3bcd85279c5894f378ec09f08c2908" => :sierra
    sha256 "5ac2dcd6bf2295d5656eeba5f637b54fd5b8aae354f92c7e16013cd264632adf" => :el_capitan
    sha256 "f16610e281f5a7983c1daa8c1f44392b20d109d41af16126ac776f17cf4f3191" => :yosemite
  end

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    ENV["GOBIN"] = bin

    ln_s buildpath/"dist/src", buildpath/"src"
    system "go", "install", "-v", "github.com/lxc/lxd/lxc"
  end

  test do
    system "#{bin}/lxc", "--version"
  end
end
