class Mpfr < Formula
  desc "C library for multiple-precision floating-point computations"
  homepage "http://www.mpfr.org/"
  url "https://ftp.gnu.org/gnu/mpfr/mpfr-3.1.6.tar.xz"
  mirror "https://ftpmirror.gnu.org/mpfr/mpfr-3.1.6.tar.xz"
  sha256 "7a62ac1a04408614fccdc506e4844b10cf0ad2c2b1677097f8f35d3a1344a950"

  bottle do
    cellar :any
    sha256 "563898b76509b25a1c7ed09c3f541310569d7c124f1edc84638ecec75e507698" => :sierra
    sha256 "f9ae415a51042ad963dfd8d6171556b0119a27edbe894614c0e3a2e4398515c4" => :el_capitan
    sha256 "ca737c71556161c37563b78305aa93c6663cde07f06d94e4d7de091983327c48" => :yosemite
  end

  depends_on "gmp"

  fails_with :clang do
    build 421
    cause <<-EOS.undent
      clang build 421 segfaults while building in superenv;
      see https://github.com/Homebrew/homebrew/issues/15061
    EOS
  end

  def install
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}",
                          "--disable-silent-rules"
    system "make"
    system "make", "check"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
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
