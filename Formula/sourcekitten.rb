class Sourcekitten < Formula
  desc "Framework and command-line tool for interacting with SourceKit"
  homepage "https://github.com/jpsim/SourceKitten"
  url "https://github.com/jpsim/SourceKitten.git",
      :tag      => "0.23.0",
      :revision => "421a1ec6112b83265b63a163107c9b638dc56e86"
  head "https://github.com/jpsim/SourceKitten.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "32ce2eb944de73faf712b7314708bb10e11c37ff99cdd2326663f3e662d244d4" => :mojave
    sha256 "dadffd1d44d3365bdacefa3beb320f2d2fcdc832287a388068b659b3ecca2a15" => :high_sierra
  end

  depends_on :xcode => "10.0"

  def install
    system "make", "prefix_install", "PREFIX=#{prefix}", "TEMPORARY_FOLDER=#{buildpath}/SourceKitten.dst"
  end

  test do
    # Rewrite test after sandbox issues investigated.
    # https://github.com/Homebrew/homebrew/pull/50211
    system "#{bin}/sourcekitten", "version"
  end
end
