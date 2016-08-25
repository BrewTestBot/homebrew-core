class Valgrind < Formula
  desc "Dynamic analysis tools (memory, debug, profiling)"
  homepage "http://www.valgrind.org/"

  stable do
    url "http://valgrind.org/downloads/valgrind-3.11.0.tar.bz2"
    sha256 "6c396271a8c1ddd5a6fb9abe714ea1e8a86fce85b30ab26b4266aeb4c2413b42"

    # Fix tst->os_state.pthread - magic_delta assertion failure on OSX 10.11
    # https://bugs.kde.org/show_bug.cgi?id=354883
    # https://github.com/liquid-mirror/valgrind/commit/8f0b10fdc795f6011c17a7d80a0d65c36fcb8619.diff
    patch :DATA
  end

  bottle do
    rebuild 1
    sha256 "a3c04e2e496a5600c775fea8bad6a0be20e7fbe2bc9766c596ad1feeed06acc1" => :el_capitan
    sha256 "2052d5bc419c5457dc59688834549e8baa1788a22bd2a434e094a6f01263865f" => :yosemite
    sha256 "75d83fa87f6b96b5fd572a58f73ab49dbae7cdd1b4fd74df67f37a881c60f5c4" => :mavericks
  end

  head do
    url "svn://svn.valgrind.org/valgrind/trunk"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on :macos => :snow_leopard

  # Valgrind needs vcpreload_core-*-darwin.so to have execute permissions.
  # See #2150 for more information.
  skip_clean "lib/valgrind"

  def install
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
    ]
    if MacOS.prefer_64_bit?
      args << "--enable-only64bit" << "--build=amd64-darwin"
    else
      args << "--enable-only32bit"
    end

    system "./autogen.sh" if build.head?

    # Look for headers in the SDK on Xcode-only systems: https://bugs.kde.org/show_bug.cgi?id=295084
    unless MacOS::CLT.installed?
      inreplace "coregrind/Makefile.in", %r{(\s)(?=/usr/include/mach/)}, '\1'+MacOS.sdk_path.to_s
    end

    system "./configure", *args
    system "make"
    system "make", "install"
  end

  test do
    system "#{bin}/valgrind", "ls", "-l"
  end
end
__END__
diff --git a/coregrind/m_syswrap/syswrap-amd64-darwin.c b/coregrind/m_syswrap/syswrap-amd64-darwin.c
index 8f13e71..7fb8b2c 100644
--- a/coregrind/m_syswrap/syswrap-amd64-darwin.c
+++ b/coregrind/m_syswrap/syswrap-amd64-darwin.c
@@ -479,10 +479,8 @@ void wqthread_hijack(Addr self, Addr kport, Addr stackaddr, Addr workitem,
        UWord magic_delta = 0;
 #      elif DARWIN_VERS == DARWIN_10_7 || DARWIN_VERS == DARWIN_10_8
        UWord magic_delta = 0x60;
-#      elif DARWIN_VERS == DARWIN_10_9 || DARWIN_VERS == DARWIN_10_10
+#      elif DARWIN_VERS == DARWIN_10_9 || DARWIN_VERS == DARWIN_10_10 || DARWIN_VERS == DARWIN_10_11
        UWord magic_delta = 0xE0;
-#      elif DARWIN_VERS == DARWIN_10_11
-       UWord magic_delta = 0x100;
 #      else
 #        error "magic_delta: to be computed on new OS version"
          // magic_delta = tst->os_state.pthread - self
diff --git a/coregrind/m_syswrap/syswrap-x86-darwin.c b/coregrind/m_syswrap/syswrap-x86-darwin.c
index a9282ee..37bbbc3 100644
--- a/coregrind/m_syswrap/syswrap-x86-darwin.c
+++ b/coregrind/m_syswrap/syswrap-x86-darwin.c
@@ -427,10 +427,8 @@ void wqthread_hijack(Addr self, Addr kport, Addr stackaddr, Addr workitem,
       UWord magic_delta = 0;
 #     elif DARWIN_VERS == DARWIN_10_7 || DARWIN_VERS == DARWIN_10_8
       UWord magic_delta = 0x48;
-#     elif DARWIN_VERS == DARWIN_10_9 || DARWIN_VERS == DARWIN_10_10
+#     elif DARWIN_VERS == DARWIN_10_9 || DARWIN_VERS == DARWIN_10_10 || DARWIN_VERS == DARWIN_10_11
       UWord magic_delta = 0xB0;
-#     elif DARWIN_VERS == DARWIN_10_11
-      UWord magic_delta = 0x100;
 #     else
 #       error "magic_delta: to be computed on new OS version"
         // magic_delta = tst->os_state.pthread - self
