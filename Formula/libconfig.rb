class Libconfig < Formula
  desc "Configuration file processing library"
  homepage "http://www.hyperrealm.com/libconfig/"
  url "https://github.com/hyperrealm/libconfig/archive/v1.6.tar.gz"
  sha256 "18739792eb463d73525d7aea9b0a48b14106fae1cfec09aedc668d8c1079adf1"

  bottle do
    cellar :any
    sha256 "39a2e2d85ca89f895832cfa75710cb9094c3d4e315d7b45db58ebb7fb626a984" => :el_capitan
    sha256 "04d66c5f07d74f31a5b57a6bb50d0c2b73222876e6c4ba40470bfb852e6f7b99" => :yosemite
    sha256 "b48857221d7df42fdfb5a1e8a61da669ca2d30331539797e57d436d8cd78f4c9" => :mavericks
    sha256 "3053bef646c2eb74d9f9a723a496a09d786a3e46e193993a0c10281b28500e50" => :mountain_lion
  end

  head do
    url "https://github.com/hyperrealm/libconfig.git"
    depends_on "automake" => :build
    depends_on "autoconf" => :build
    depends_on "libtool" => :build
  end

  option :universal

  def install
    ENV.universal_binary if build.universal?

    system "autoreconf", "-i" if build.head?
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"

    # Fixes "scanner.l:137:59: error: too few arguments to function call ..."
    # Forces regeneration of the BUILT_SOURCES "scanner.c" and "scanner.h"
    # Reported 6 Jun 2016: https://github.com/hyperrealm/libconfig/issues/66
    touch "lib/scanner.l"

    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <libconfig.h>
      int main() {
        config_t cfg;
        config_init(&cfg);
        config_destroy(&cfg);
        return 0;
      }
    EOS
    system ENV.cc, "-I#{include}", "-L#{lib}", "-lconfig",
           testpath/"test.c", "-o", testpath/"test"
    system "./test"
  end
end
