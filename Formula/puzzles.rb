class Puzzles < Formula
  desc "Collection of one-player puzzle games"
  homepage "https://www.chiark.greenend.org.uk/~sgtatham/puzzles/"
  # Extract https://www.chiark.greenend.org.uk/~sgtatham/puzzles/puzzles.tar.gz to get the version number
  url "https://www.chiark.greenend.org.uk/~sgtatham/puzzles/puzzles-20181213.ced51ad.tar.gz"
  version "20181213"
  sha256 "af6f4a5e24ed5e45f5970094861baaca968b465800618a27add54b007846d677"
  head "https://git.tartarus.org/simon/puzzles.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "51ebb5b34f2b5c0c7b26d9a474c3e31d82d0dec73ca3b8c08b07dc22a331f41b" => :mojave
    sha256 "6689b218a12a6d2d7040c1bc74907a617e53e90861500d107fc18917719e8f92" => :high_sierra
    sha256 "e1fcd9573717c26270ee4597059337ea9d51e3d660d3aac47e5cdd9748b8f85e" => :sierra
  end

  depends_on "halibut"

  def install
    # Do not build for i386
    inreplace "mkfiles.pl", /@osxarchs = .*/, "@osxarchs = ('x86_64');"

    system "perl", "mkfiles.pl"
    system "make", "-d", "-f", "Makefile.osx", "all"
    prefix.install "Puzzles.app"
  end

  test do
    assert_predicate prefix/"Puzzles.app/Contents/MacOS/Puzzles", :executable?
  end
end
