class Pdftoedn < Formula
  desc "Extract PDF document data and save the output in EDN format"
  homepage "https://github.com/edporras/pdftoedn"
  url "https://github.com/edporras/pdftoedn/archive/v0.35.1.tar.gz"
  sha256 "566b9ed81a60aa2579da60e2ae0f7d73292a1f7ba41280e392c0d4b1297e49b9"
  revision 1

  bottle do
    cellar :any
    sha256 "0ed573c69a5421c8b6b5384435c4975600616706fac88bed43e5881443522c58" => :high_sierra
    sha256 "523ed7b4e3a765c5109d8d59699c8bbbd2d50523e5e29122ffe855b680458488" => :sierra
    sha256 "e039c40054035ae7af493adc8dbc00d78f31ac0a872b76801e881bf53fa6aa00" => :el_capitan
  end

  needs :cxx11
  depends_on "automake" => :build
  depends_on "autoconf" => :build
  depends_on "pkg-config" => :build
  depends_on "freetype"
  depends_on "libpng"
  depends_on "poppler"
  depends_on "boost"
  depends_on "leptonica"
  depends_on "openssl"
  depends_on "rapidjson"

  def install
    ENV.cxx11

    system "autoreconf", "-i"
    system "./configure", "--with-openssl=#{Formula["openssl"].opt_prefix}", "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end

  test do
    system "#{bin}/pdftoedn", "-o", "test.edn", test_fixtures("test.pdf")
  end
end
