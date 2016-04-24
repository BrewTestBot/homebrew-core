class Pacapt < Formula
  desc "Package manager in the style or Arch's pacman"
  homepage "https://github.com/icy/pacapt"
  url "https://github.com/icy/pacapt/archive/v2.2.7.tar.gz"
  sha256 "9cc754c9005a50407412ac8520ba20a7c612553f31059ad47289bc3df2a6b254"

  bottle do
    cellar :any_skip_relocation
    sha256 "ea561737a83a5d24692a22c39f8c5358f4ca6a110b22d03c383ab2b889ef3bcb" => :el_capitan
    sha256 "6ddfadf6010ce7caace02875e5fbd63777febfc3c4902ebe1d1e6c878af81cbb" => :yosemite
    sha256 "1bef258671dfe35071155f5a22d1e95fb4f10ab0cf54d11a8e95c1108e16f404" => :mavericks
    sha256 "b4fd2b945a12952653ea3bcfa70bbe60910b81ed890283531d217ff33a4ce812" => :mountain_lion
  end

  def install
    bin.mkpath
    system "make", "install", "BINDIR=#{bin}", "VERSION=#{version}"
  end

  test do
    system "#{bin}/pacapt", "-Ss", "wget"
  end
end
