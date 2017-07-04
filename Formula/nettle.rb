class Nettle < Formula
  desc "Low-level cryptographic library"
  homepage "https://www.lysator.liu.se/~nisse/nettle/"
  url "https://ftp.gnu.org/gnu/nettle/nettle-3.3.tar.gz"
  mirror "https://ftpmirror.gnu.org/nettle/nettle-3.3.tar.gz"
  sha256 "46942627d5d0ca11720fec18d81fc38f7ef837ea4197c1f630e71ce0d470b11e"

  bottle do
    cellar :any
    rebuild 1
    sha256 "34fe87f2e4690b46d85c3ac70336ea15910d0fd78de5192a05afb85123be9122" => :sierra
    sha256 "7edd3de240a88c2319f559656d2d825f75b8867671f51268fcf7f29531acc421" => :el_capitan
    sha256 "61c23d26ddcaa31edc1d2327d247588c7ea492f5a508f97b4bea4b81daaaf63c" => :yosemite
  end

  depends_on "gmp"

  def install
    # macOS doesn't use .so libs. Emailed upstream 04/02/2016.
    inreplace "testsuite/dlopen-test.c", "libnettle.so", "libnettle.dylib"

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--enable-shared"
    system "make"
    system "make", "install"
    system "make", "check"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <nettle/sha1.h>
      #include <stdio.h>

      int main()
      {
        struct sha1_ctx ctx;
        uint8_t digest[SHA1_DIGEST_SIZE];
        unsigned i;

        sha1_init(&ctx);
        sha1_update(&ctx, 4, "test");
        sha1_digest(&ctx, SHA1_DIGEST_SIZE, digest);

        printf("SHA1(test)=");

        for (i = 0; i<SHA1_DIGEST_SIZE; i++)
          printf("%02x", digest[i]);

        printf("\\n");
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-lnettle", "-o", "test"
    system "./test"
  end
end
