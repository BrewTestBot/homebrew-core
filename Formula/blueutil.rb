class Blueutil < Formula
  desc "Get/set bluetooth power and discoverable state"
  homepage "https://github.com/toy/blueutil"
  url "https://github.com/toy/blueutil/archive/v1.1.2.tar.gz"
  sha256 "cd23f389c5366584a5cf5679224da8811c17a6862282220abe28f7c91d3ed0cc"

  head "https://github.com/toy/blueutil.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "321ae52b2c801a5baff84f40e0a8dabeb47186b3cfcf1997c2417127d9b362d8" => :sierra
    sha256 "a1f609b801cedbd69d60288c4cb07c03a55fbf4dbd753b32243200fc2ede6e87" => :el_capitan
    sha256 "763607470c2121df23851cd4a6b624f6d3fc403df686f4f43bcc65222dc08455" => :yosemite
  end

  depends_on :xcode => :build

  def install
    # Set to build with SDK=macosx10.6, but it doesn't actually need 10.6
    xcodebuild "SDKROOT=", "SYMROOT=build"
    bin.install "build/Release/blueutil"
  end

  test do
    system "#{bin}/blueutil"
  end
end
