class Dialog < Formula
  desc "Display user-friendly message boxes from shell scripts"
  homepage "https://invisible-island.net/dialog/"
  url "https://invisible-mirror.net/archives/dialog/dialog-1.3-20190211.tgz"
  sha256 "49c0e289d77dcd7806f67056c54f36a96826a9b73a53fb0ffda1ffa6f25ea0d3"

  bottle do
    cellar :any_skip_relocation
    sha256 "c356e3a474ebf3d580ec4674d87aec9c88ba7137e0f6fefd8c73cbf99d327b76" => :mojave
    sha256 "cf169dff8e776ac85d3a662db2abd9fbd578affc994dcb866547ee06630b68f6" => :high_sierra
    sha256 "68b0c43919cde70242f56ba550b666c2a6f9e6baefca50615923efa262052d5b" => :sierra
  end

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make", "install-full"
  end

  test do
    system "#{bin}/dialog", "--version"
  end
end
