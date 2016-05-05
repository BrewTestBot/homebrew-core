class Qtfaststart < Formula
  desc "Utility for Quicktime files"
  homepage "https://libav.org/"
  url "https://libav.org/releases/libav-11.6.tar.gz"
  sha256 "4df17921e3b87170d54b738f09241833c618d2173415adf398207b43d27e4b28"

  bottle do
    cellar :any_skip_relocation
    sha256 "77aac045ac61652f58012dc5f0661e67f7b4a7b4b6fffb471be792ba145f2b31" => :el_capitan
    sha256 "2a489212e330d6286bc3cad6c8d03f5f29313c0d4e41dc84193c6f6efc8597b8" => :yosemite
    sha256 "3c4a8acf49e665b22b088246ec5b06c8e92077e0f7f64e3445a69e2a76742391" => :mavericks
    sha256 "e97d00bb8dac4155d6040e0d28be3134d7d64e0aced0503b255f0fd763efdca9" => :mountain_lion
  end

  resource "mov" do
    url "http://download.wavetlan.com/SVV/Media/HTTP/H264/Talkinghead_Media/H264_test4_Talkingheadclipped_mov_480x320.mov"
    sha256 "5af004e182ac7214dadf34816086d0a25c7a6cac568ae3741fca527cbbd242fc"
  end

  def install
    system ENV.cc, "-o", "tools/qt-faststart", "tools/qt-faststart.c"
    bin.install "tools/qt-faststart"
  end

  test do
    input = "H264_test4_Talkingheadclipped_mov_480x320.mov"
    output = "out.mov"
    resource("mov").stage testpath
    system "#{bin}/qt-faststart", input, output

    assert File.exist? output
  end
end
