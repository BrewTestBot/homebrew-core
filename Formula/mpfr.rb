class Mpfr < Formula
  desc "C library for multiple-precision floating-point computations"
  homepage "https://www.mpfr.org/"
  url "https://ftp.gnu.org/gnu/mpfr/mpfr-4.0.2.tar.xz"
  mirror "https://ftpmirror.gnu.org/mpfr/mpfr-4.0.2.tar.xz"
  sha256 "1d3be708604eae0e42d578ba93b390c2a145f17743a744d8f3f8c2ad5855a38a"

  bottle do
    cellar :any
    rebuild 1
    sha256 "5ba7562e87bed0dfa443a0c0f04b73dc6da88b383da4bc06311716a803624303" => :catalina
    sha256 "74027696acb1272f427730e5fcbb168df8ce6a3b09870734b2e41e894c554f5e" => :mojave
    sha256 "44a69a23de2868255f86f27a3eb217847444e9f82742dabc57e71c993a94124e" => :high_sierra
  end

  depends_on "gmp"

  def install
    # Work around macOS Catalina / Xcode 11 code generation bug
    # (test failure t-toom53, due to wrong code in mpn/toom53_mul.o)
    ENV.append_to_cflags "-fno-stack-check"

    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}",
                          "--disable-silent-rules"
    system "make"
    system "make", "check"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <mpfr.h>
      #include <math.h>
      #include <stdlib.h>

      int main() {
        mpfr_t x, y;
        mpfr_inits2 (256, x, y, NULL);
        mpfr_set_ui (x, 2, MPFR_RNDN);
        mpfr_root (y, x, 2, MPFR_RNDN);
        mpfr_pow_si (x, y, 4, MPFR_RNDN);
        mpfr_add_si (y, x, -4, MPFR_RNDN);
        mpfr_abs (y, y, MPFR_RNDN);
        if (fabs(mpfr_get_d (y, MPFR_RNDN)) > 1.e-30) abort();
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-L#{Formula["gmp"].opt_lib}",
                   "-lgmp", "-lmpfr", "-o", "test"
    system "./test"
  end
end
