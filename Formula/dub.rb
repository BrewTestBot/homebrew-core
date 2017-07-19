class Dub < Formula
  desc "Build tool for D projects"
  homepage "https://code.dlang.org/getting_started"
  url "https://github.com/dlang/dub/archive/v1.4.0.tar.gz"
  sha256 "11e2604e61fb89152044927df1f87561640da8406ea4bdb35655572bbdfd77f0"
  version_scheme 1

  head "https://github.com/dlang/dub.git"

  bottle do
    sha256 "6f7d63d42f60d169dd756ff518a935c2c03cea10dafe2ee5028e82e022393143" => :sierra
    sha256 "827b58d1f554b3892c69d2ffaaf2d4c9ba6703d598f436444ed5032d62943180" => :el_capitan
    sha256 "b0882c369fb17175f79b2f4b469d91dc0da2bd777686fabbbe53b02ff259d412" => :yosemite
  end

  depends_on "pkg-config" => [:recommended, :run]
  depends_on "dmd" => :build

  def install
    ENV["GITVER"] = version.to_s
    system "./build.sh"
    bin.install "bin/dub"
  end

  test do
    if build.stable?
      assert_match version.to_s, shell_output("#{bin}/dub --version")
    else
      assert_match version.to_s, shell_output("#{bin}/dub --version").split(/[ ,]/)[2]
    end
  end
end
