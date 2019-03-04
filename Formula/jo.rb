class Jo < Formula
  desc "JSON output from a shell"
  homepage "https://github.com/jpmens/jo"
  url "https://github.com/jpmens/jo/releases/download/1.2/jo-1.2.tar.gz"
  sha256 "36ec2fc4937c6478467684b18f0b213ff7267d34f5626cd5a0996a39ca64adae"

  bottle do
    cellar :any_skip_relocation
    sha256 "4241b365751320df8483499f90f2f1361e20de4fa4137dc7be101d920ee57789" => :mojave
    sha256 "60c2de40a59a6caab00a3d23467e4b87e7388f7daca7307e84fb318a9f4a1352" => :high_sierra
    sha256 "8d0f2a55eb728d06f4640675d6aeec5de0a967fa2aa2614af211822c77548154" => :sierra
    sha256 "e1661162b8b18fbffa42a488a56748c2b368329fc2f0cc5fb5947fc98f049e8d" => :el_capitan
    sha256 "e5dc735e45b7eff98a43c8b9279b6d3a9b1992d8e8eab5a6e999af4cc31afbf3" => :yosemite
  end

  head do
    url "https://github.com/jpmens/jo.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
  end

  def install
    system "autoreconf", "-i" if build.head?

    system "./configure", "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    assert_equal %Q({"success":true,"result":"pass"}\n), pipe_output("#{bin}/jo success=true result=pass")
  end
end
