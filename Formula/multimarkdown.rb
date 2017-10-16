class Multimarkdown < Formula
  desc "Turn marked-up plain text into well-formatted documents"
  homepage "http://fletcherpenney.net/multimarkdown/"
  # Use git tag instead of the tarball to get submodules
  url "https://github.com/fletcher/MultiMarkdown-6.git",
    :tag => "6.2.2",
    :revision => "97503e55cac9b67721eed0874b4d5135d7ac5b59"

  head "https://github.com/fletcher/MultiMarkdown-6.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "5a317e9e6bb5a56ff216228b449ce1644271641591ccc567097bdb6c9adb41b5" => :high_sierra
    sha256 "cc9f163eaa9eb53def1e66cd2e3871ea9f8274028a3d399d01e2944d8cf2ac6f" => :sierra
    sha256 "72571c5521bda002ce2b140bc7e8fd224c0545e9f21b6268ad5a2ecedfe4e025" => :el_capitan
    sha256 "7c5370be42b0e15b19da90d8ead5aec745e24c842aea2cf2c210f399d84b67d8" => :yosemite
    sha256 "475aed59ab53d010d8238fb8d0646c43de994c46893baecabcbcfc33c99b15fc" => :mavericks
  end

  depends_on "cmake" => :build

  conflicts_with "mtools", :because => "both install `mmd` binaries"
  conflicts_with "markdown", :because => "both install `markdown` binaries"
  conflicts_with "discount", :because => "both install `markdown` binaries"

  def install
    system "sh", "link_git_modules"
    system "sh", "update_git_modules"
    system "make"

    cd "build" do
      system "make"
      bin.install "multimarkdown"
    end

    bin.install Dir["scripts/*"].reject { |f| f =~ /\.bat$/ }
  end

  test do
    assert_equal "<p>foo <em>bar</em></p>\n", pipe_output(bin/"multimarkdown", "foo *bar*\n")
    assert_equal "<p>foo <em>bar</em></p>\n", pipe_output(bin/"mmd", "foo *bar*\n")
  end
end
