class Ffms2 < Formula
  desc "Libav/ffmpeg based source library and Avisynth plugin"
  homepage "https://github.com/FFMS/ffms2"
  url "https://github.com/FFMS/ffms2/archive/2.23.tar.gz"
  mirror "https://deb.debian.org/debian/pool/main/f/ffms2/ffms2_2.23.orig.tar.gz"
  sha256 "b09b2aa2b1c6f87f94a0a0dd8284b3c791cbe77f0f3df57af99ddebcd15273ed"
  revision 3

  bottle do
    cellar :any
    sha256 "abab9c354d4d4eb0b86dcad80f451820fe1e55a81f74373f29b3a17731002d26" => :catalina
    sha256 "184f414d0b9cbebf4e809ca5b49511d31d800d0bfc792eebe7bdf408cc813135" => :mojave
    sha256 "e040a822f983e7d18e018efb8ca14e6c24a2c8712a146efc1b8911dc7b8695bd" => :high_sierra
  end

  head do
    url "https://github.com/FFMS/ffms2.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
  end

  depends_on "pkg-config" => :build
  depends_on "ffmpeg"

  resource "videosample" do
    url "https://samples.mplayerhq.hu/V-codecs/lm20.avi"
    sha256 "a0ab512c66d276fd3932aacdd6073f9734c7e246c8747c48bf5d9dd34ac8b392"
  end

  def install
    # For Mountain Lion
    ENV.libcxx

    args = %W[
      --disable-debug
      --disable-dependency-tracking
      --enable-avresample
      --prefix=#{prefix}
    ]

    if build.head?
      system "./autogen.sh", *args
    else
      system "./configure", *args
    end

    system "make", "install"
  end

  test do
    # download small sample and check that the index was created
    resource("videosample").stage do
      system bin/"ffmsindex", "lm20.avi"
      assert_predicate Pathname.pwd/"lm20.avi.ffindex", :exist?
    end
  end
end
