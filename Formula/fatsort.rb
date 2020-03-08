class Fatsort < Formula
  desc "Sorts FAT16 and FAT32 partitions"
  homepage "https://fatsort.sourceforge.io/"
  url "https://downloads.sourceforge.net/project/fatsort/fatsort-1.6.2.605.tar.xz"
  version "1.6.2"
  sha256 "08cafa36f86ab89e7a3241d437df9af8a008549d7d13416256b7aaa006d5ffb7"

  bottle do
    cellar :any_skip_relocation
    sha256 "ace9262fe6a7ba67ae184d01e192ea94089c241448034aad9c0e3ebd56db3b92" => :catalina
    sha256 "30317b1edc9c062183ca98bf20baca935bf129405e15fc89056659968e33a83b" => :mojave
    sha256 "d9e23a82a00b9747f24e78e2fc11f40ea8bebadfafa41fa7d5c2e6838d6514b7" => :high_sierra
    sha256 "fd941f1bc940edcd9d23860ce723355be2249e330ecc8bbab4c5713525c78963" => :sierra
  end

  depends_on "help2man"

  def install
    system "make", "CC=#{ENV.cc}"
    bin.install "src/fatsort"
    man1.install "man/fatsort.1"
  end

  test do
    system "#{bin}/fatsort", "--version"
  end
end
