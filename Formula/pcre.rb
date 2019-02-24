class Pcre < Formula
  desc "Perl compatible regular expressions library"
  homepage "https://www.pcre.org/"
  url "https://ftp.pcre.org/pub/pcre/pcre-8.43.tar.bz2"
  sha256 "91e762520003013834ac1adb4a938d53b22a216341c061b0cf05603b290faf6b"

  bottle do
    cellar :any
    sha256 "f848e72c9a6ddfdd4e57d25df859830187cbb8e850996b22a84270a6590f56ff" => :mojave
    sha256 "b904c008c04003c3f40e30c6ee6a3b411aad81aa2f2684db9bf59bccd9d58b01" => :high_sierra
    sha256 "d8f8faec67df2d86e12757cac6f076c48d0fafac8f2a88c87c64d5807dce7142" => :sierra
    sha256 "b07b9523cbab3c86423fecc7f5e79a1eb9dd47958d915f8915c78e6faa4f4435" => :el_capitan
  end

  head do
    url "svn://vcs.exim.org/pcre/code/trunk"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  def install
    system "./autogen.sh" if build.head?
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--enable-utf8",
                          "--enable-pcre8",
                          "--enable-pcre16",
                          "--enable-pcre32",
                          "--enable-unicode-properties",
                          "--enable-pcregrep-libz",
                          "--enable-pcregrep-libbz2",
                          "--enable-jit"
    system "make"
    ENV.deparallelize
    system "make", "test"
    system "make", "install"
  end

  test do
    system "#{bin}/pcregrep", "regular expression", "#{prefix}/README"
  end
end
