class Libidn < Formula
  desc "International domain name library"
  homepage "https://www.gnu.org/software/libidn/"
  url "https://ftp.gnu.org/gnu/libidn/libidn-1.34.tar.gz"
  mirror "https://ftpmirror.gnu.org/libidn/libidn-1.34.tar.gz"
  sha256 "3719e2975f2fb28605df3479c380af2cf4ab4e919e1506527e4c7670afff6e3c"

  bottle do
    cellar :any
    sha256 "0af53718a30d295afa6c6cc1336c5208aa89f119e03115feb46818842ce65176" => :high_sierra
    sha256 "02995ada0a4e1c66d073dd66252e7fd58d8fe3f2a9be13ca29b081b611bc43ef" => :sierra
    sha256 "b46b71b9adb991af6a444400a1c3f53d20b8001792855bcf96044ce33eb81d26" => :el_capitan
    sha256 "f675600e756059cdcd02d92963ff76f43c3b572f4ea9f99657a40e9e80c316b1" => :yosemite
    sha256 "07e19d25263d77030cccc3899967c4505dcf0c771da90a658b4f27de136a326b" => :mavericks
  end

  depends_on "pkg-config" => :build

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--disable-csharp",
                          "--with-lispdir=#{elisp}"
    system "make", "install"
  end

  test do
    ENV["CHARSET"] = "UTF-8"
    system bin/"idn", "räksmörgås.se", "blåbærgrød.no"
  end
end
