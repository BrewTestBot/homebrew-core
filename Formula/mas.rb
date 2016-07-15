class Mas < Formula
  desc "Mac App Store command-line interface"
  homepage "https://github.com/argon/mas"
  url "https://github.com/argon/mas/archive/v1.2.0.tar.gz"
  sha256 "79a30d2b8c053a33b69a255da3ad35a96a337f0b9dded5112e6e48cdadddf73a"
  head "https://github.com/argon/mas.git"

  bottle do
    cellar :any_skip_relocation
    revision 1
    sha256 "25250810a17b0a8d4f5f06e524f2a4bff9e5a12734da1e50f25ded9b070c7e2a" => :el_capitan
  end

  depends_on :xcode => ["7.3", :build]

  def install
    ENV["GEM_HOME"] = buildpath/".gem"
    system "gem", "install", "bundler"
    ENV.prepend_path "PATH", "#{ENV["GEM_HOME"]}/bin"
    system "script/bootstrap"
    xcodebuild "-project", "mas-cli.xcodeproj",
               "-scheme", "mas-cli",
               "-configuration", "Release",
               "SYMROOT=build"
    bin.install "build/mas"
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/mas version").chomp
  end
end
