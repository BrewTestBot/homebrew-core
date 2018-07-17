class Fakeroot < Formula
  desc "Provide a fake root environment"
  homepage "https://tracker.debian.org/pkg/fakeroot"
  url "http://archive.ubuntu.com/ubuntu/pool/main/f/fakeroot/fakeroot_1.22.orig.tar.bz2"
  mirror "http://ftp.internat.freebsd.org/pub/FreeBSD/ports/distfiles/fakeroot_1.22.orig.tar.bz2"
  sha256 "bd806a4a1e641203eb3d4571a10089e8a038c10ec7e492fa1e061b03ae3ec6fe"

  bottle do
    cellar :any
    rebuild 1
    sha256 "b51c80a046d437fbe2b86f690344df35649b6d54ef4a64d0ecf0e75eeea52631" => :high_sierra
    sha256 "deacd5ccbb553a9aa084d5f081b73f919240b8f47b37aa8bd4263c319d29044c" => :sierra
    sha256 "7f470b37cd3083f4afba7fa51a51a20716adf438a2d230a3b880bff5ea556506" => :el_capitan
  end

  # Compile is broken. https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=766649
  # Patches submitted upstream on 24/10/2014, but no reply from maintainer thus far.
  patch do
    url "https://bugs.debian.org/cgi-bin/bugreport.cgi?msg=5;filename=0001-Implement-openat-2-wrapper-which-handles-optional-ar.patch;att=1;bug=766649"
    sha256 "1c9a24aae6dc2a82fa7414454c12d3774991f6264dd798d7916972335602308d"
  end

  patch do
    url "https://bugs.debian.org/cgi-bin/bugreport.cgi?msg=5;filename=0002-OS-X-10.10-introduced-id_t-int-in-gs-etpriority.patch;att=2;bug=766649"
    sha256 "e0823a8cfe9f4549eb4f0385a9cd611247c3a11c0452b5f80ea6122af4854b7c"
  end

  # This patch handles mapping the variadic arguments to the system openat to
  # the fixed arguments for our next_openat function.
  # Patch has been submitted to
  # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=766649
  patch :DATA

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-static",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"

    # Yosemite introduces an openat function, which has variadic arguments,
    # which the "fancy" wrapping scheme used by fakeroot does not handle. So we
    # have to patch the generated file after it is generated.
    # Patch has been submitted with detailed explanation to
    # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=766649
    system "make", "wraptmpf.h"
    (buildpath/"patch-for-wraptmpf-h").write <<~EOS
      diff --git a/wraptmpf.h b/wraptmpf.h
      index dbfccc9..0e04771 100644
      --- a/wraptmpf.h
      +++ b/wraptmpf.h
      @@ -575,6 +575,10 @@ static __inline__ int next_mkdirat (int dir_fd, const char *pathname, mode_t mod
       #endif /* HAVE_MKDIRAT */
       #ifdef HAVE_OPENAT
       extern int openat (int dir_fd, const char *pathname, int flags, ...);
      +static __inline__ int next_openat (int dir_fd, const char *pathname, int flags, mode_t mode) __attribute__((always_inline));
      +static __inline__ int next_openat (int dir_fd, const char *pathname, int flags, mode_t mode) {
      +  return openat (dir_fd, pathname, flags, mode);
      +}

       #endif /* HAVE_OPENAT */
       #ifdef HAVE_RENAMEAT
    EOS

    system "patch < patch-for-wraptmpf-h"

    system "make"
    system "make", "install"
  end

  test do
    if MacOS.version <= :yosemite
      assert_equal "root", shell_output("#{bin}/fakeroot whoami").strip
    else
      assert_match version.to_s, shell_output("#{bin}/fakeroot -v")
    end
  end
end

__END__
index 15fdd1d..29d738d 100644
--- a/libfakeroot.c
+++ b/libfakeroot.c
@@ -2446,6 +2446,6 @@ int openat(int dir_fd, const char *pathname, int flags, ...)
         va_end(args);
         return next_openat(dir_fd, pathname, flags, mode);
     }
-    return next_openat(dir_fd, pathname, flags);
+    return next_openat(dir_fd, pathname, flags, NULL);
 }
 #endif
