class Lrzip < Formula
  desc "Compression program with a very high compression ratio"
  homepage "http://lrzip.kolivas.org"
  url "http://ck.kolivas.org/apps/lrzip/lrzip-0.631.tar.bz2"
  sha256 "0d11e268d0d72310d6d73a8ce6bb3d85e26de3f34d8a713055f3f25a77226455"

  bottle do
    cellar :any
    sha256 "aa49a3b90dcf1505c5e7802cf06dbfb99ae6b286f8f5047f8d9f8162a277f364" => :sierra
    sha256 "3e1961f7015e80bba9423c8ac937873291c282d7429d40442e2f24323a1d558c" => :el_capitan
    sha256 "be8250575e5bb6b3e322d9ca26f333c2918668672349e8f3a489c7d1ddbc4c30" => :yosemite
    sha256 "188a28b951eda33fc61bb166a2dd0ab44990d471535e746eadaf9ba8ad095cb5" => :mavericks
    sha256 "1a36857c2c25388efe5fd26b52bb7501084ef2b0d94dec353debf14222f9a849" => :mountain_lion
  end

  depends_on "pkg-config" => :build
  depends_on "lzo"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end

  test do
    path = testpath/"data.txt"
    original_contents = "." * 1000
    path.write original_contents

    # compress: data.txt -> data.txt.lrz
    system bin/"lrzip", "-o", "#{path}.lrz", path
    path.unlink

    # decompress: data.txt.lrz -> data.txt
    system bin/"lrzip", "-d", "#{path}.lrz"
    assert_equal original_contents, path.read
  end
end
