class Gphoto2 < Formula
  desc "Command-line interface to libgphoto2"
  homepage "http://gphoto.org/"
  url "https://downloads.sourceforge.net/project/gphoto/gphoto/2.5.10/gphoto2-2.5.10.tar.bz2"
  sha256 "66cc2f535d54b7e5a2164546a8955a58e23745e91e916757c0bf070699886690"

  bottle do
    cellar :any
    sha256 "f570a7e2cd5a68785ec706283f5eaabc706d330243019ad8aabed72e837d6a06" => :el_capitan
    sha256 "7ad0a0e1cb35c51c4a913c2d27b7dbf684326126e5daf1ac7c6abdc8a0499e24" => :yosemite
    sha256 "7da8bfde56b1081046ccb4c01cec549c75aeb0b2e272c2164e372677286138a5" => :mavericks
  end

  depends_on "pkg-config" => :build
  depends_on "jpeg"
  depends_on "libgphoto2"
  depends_on "popt"
  depends_on "readline"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    `gphoto2 -v`
  end
end
