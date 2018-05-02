class Cjdns < Formula
  desc "Advanced mesh routing system with cryptographic addressing"
  homepage "https://github.com/cjdelisle/cjdns/"
  url "https://github.com/cjdelisle/cjdns/archive/cjdns-v20.2.tar.gz"
  sha256 "b114f4e89c971d2c288e3d8265396248a37134895b0e0468bf55030de84b4d2a"
  head "https://github.com/cjdelisle/cjdns.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "c8de87eccf8e0c10f5e6b7b943c8f9e388aeccd7ac122cfa3c54edb94f1313ba" => :high_sierra
    sha256 "9b9275abfa8abc4f0ca0013b6756a4dfe254282de869cc8fac716103aee05088" => :sierra
    sha256 "25fdeeddcf62a47435f401d90975650af5a8b3a771270fe18f13aeac6d356536" => :el_capitan
  end

  depends_on "node" => :build

  def install
    system "./do"
    bin.install "cjdroute"
    (pkgshare/"test").install "build_darwin/test_testcjdroute_c" => "cjdroute_test"
  end

  test do
    system "#{pkgshare}/test/cjdroute_test", "all"
  end
end
