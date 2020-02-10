class Ncdu < Formula
  desc "NCurses Disk Usage"
  homepage "https://dev.yorhel.nl/ncdu"
  url "https://dev.yorhel.nl/download/ncdu-1.14.2.tar.gz"
  sha256 "947a7f5c1d0cd4e338e72b4f5bc5e2873651442cec3cb012e04ad2c37152c6b1"

  bottle do
    cellar :any_skip_relocation
    sha256 "757cbcc5ed617cbe01b66d04b4db07fa6ef568077f6f66eb46cbf0c0cabb3d7c" => :catalina
    sha256 "4affa4dad2978f22cb284a3efed3b63408e0e4d4d77ac851266df15386a02c30" => :mojave
    sha256 "9fcb90b8776c442b94d387f679cf8dfceb6c7f043f33212aa77ecc72db6a8ff8" => :high_sierra
    sha256 "874b76e2ff36b231358596581ed2e8536682bf17e65e5762ae5d5aa20e511a3a" => :sierra
  end

  head do
    url "https://g.blicky.net/ncdu.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
  end

  def install
    system "autoreconf", "-i" if build.head?
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ncdu -v")
  end
end
