class LibtorrentRakshasa < Formula
  desc "BitTorrent library for rTorrent"
  homepage "https://github.com/rakshasa/libtorrent"
  url "https://github.com/rakshasa/rtorrent/releases/download/v0.9.7/libtorrent-0.13.7.tar.gz"
  sha256 "c738f60f4d7b6879cd2745fb4310bf24c9287219c1fd619706a9d5499ca7ecc1"

  bottle do
    cellar :any
    sha256 "da632370569fa2920119d428a08b4007a180f981d699b00d08cc7017e730a19c" => :mojave
    sha256 "c1ce4fe631046668f0cf9984030247b3e8daf606def6d757867357ef302a5c47" => :sierra
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build
  depends_on "cppunit"
  depends_on "openssl"

  conflicts_with "libtorrent-rasterbar", :because => "both install the same binaries"

  def install
    ENV.cxx11

    ENV.delete("SDKROOT") if DevelopmentTools.clang_build_version >= 900

    ENV.append "LDFLAGS", "-lpthread"
    args = ["--without-kqueue", "--prefix=#{prefix}"]

    system "sh", "autogen.sh"
    system "./configure", *args
    system "make"
    system "make", "install"
  end

  test do
    (testpath/"sample.cc").write <<~EOS
      #include <iostream>
      #include <torrent/torrent.h>
      int main(int argc, char* *argv)
      {
        std::cout << torrent::version();
        return 0;
      }
    EOS

    system ENV.cxx, "-o", "sample", "sample.cc", "-ltorrent"
    system "./sample"
  end
end
