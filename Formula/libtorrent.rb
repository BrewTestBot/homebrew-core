class Libtorrent < Formula
  desc "BitTorrent library"
  homepage "https://github.com/rakshasa/libtorrent"
  url "https://github.com/rakshasa/rtorrent/releases/download/v0.9.7/libtorrent-0.13.7.tar.gz"
  sha256 "c738f60f4d7b6879cd2745fb4310bf24c9287219c1fd619706a9d5499ca7ecc1"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build
  depends_on "cppunit"
  depends_on "openssl"

  conflicts_with "libtorrent-rasterbar"

  def install
    ENV.append "CXXFLAGS", "-Wno-deprecated-declarations -O3 -std=c++11 -stdlib=libc++"
    ENV.append "LDFLAGS", "-isysroot #{MacOS.sdk_path}"

    args = ["--with-kqueue", "--prefix=#{prefix}"]

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
