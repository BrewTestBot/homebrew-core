class Libalac < Formula
  desc "Static & Dynamic Library for the Apple Lossless Audio Codec (ALAC)"
  homepage "https://macosforge.github.io/alac/"
  url "https://github.com/TimothyGu/alac/archive/v0.0r4+tg1.tar.gz"
  version "1.0.0"
  sha256 "97ea9376145d38d898f8d5f969d3c7a7a36aa8bcb0e93378c81fbf8d77fb913d"
  head "https://github.com/TimothyGu/alac.git"

  bottle do
    cellar :any
    sha256 "4c33221b2b3d6ac1746dabfd09b6618d6a3cf7edb2cda7310b2b68a60b8937f6" => :high_sierra
    sha256 "156bc655c05ee8ba139567872b8b4aa550577a2f1d34f143058b3132ec736d9b" => :sierra
    sha256 "af9d8b9433c7a70e26292d13ad2a6be8905d276cd033ceb5fda88058beef2ed8" => :el_capitan
  end

  depends_on "automake" => :build
  depends_on "autoconf" => :build
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build

  def install
    system "autoreconf", "-fiv"
    system "./configure", "--disable-dependency-tracking", "--disable-silent-rules", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<-EOS
      #include <stdio.h>
      #include <stdlib.h>
      #include <assert.h>
      #include <alac/ALACEncoder.h>
      #include <alac/ALACDecoder.h>

      int main() {
        uint32_t   frameSize = kALACDefaultFramesPerPacket;
        uint8_t    *magicCookie = (uint8_t *)calloc(1337, 1);

        ALACEncoder *theEncoder = new ALACEncoder;
        theEncoder->SetFrameSize(frameSize);
        assert(theEncoder != NULL);

        ALACDecoder *theDecoder = new ALACDecoder;
        theDecoder->Init(magicCookie, 1337);
        assert(theDecoder != NULL);

        return 0;
      }
    EOS
    flags = %W[
      -I#{include}
      -L#{lib}
      -lalac
    ]
    system ENV.cxx, testpath/"test.cpp", "-o", "test", *flags
    system "./test"
  end
end
