class VimAT74 < Formula
  desc "Vi 'workalike' with many additional features"
  homepage "https://www.vim.org/"
  url "https://github.com/vim/vim/archive/v7.4.2367.tar.gz"
  sha256 "a9ae4031ccd73cc60e771e8bf9b3c8b7f10f63a67efce7f61cd694cd8d7cda5c"
  revision 22

  bottle do
    sha256 "b7e898aedfcd06a3866aae2a1951b78a99c9348815484f93b07d6c68331a836d" => :mojave
    sha256 "afb0f1509b33e4c26f0a0fa43e4282f34aca6573a9290a199d3c232f22009563" => :high_sierra
    sha256 "0061cc3f741008cb7afae6e67fb10eba53b13e45d9e9dd2b01ba64cfea8455a3" => :sierra
  end

  keg_only :versioned_formula

  depends_on "lua"
  depends_on "perl"
  depends_on "python"
  depends_on "ruby"

  # Python 3.7 compat
  # Equivalent to upstream commit 24 Mar 2018 "patch 8.0.1635: undefining
  # _POSIX_THREADS causes problems with Python 3"
  # See https://github.com/vim/vim/commit/16d7eced1a08565a9837db8067c7b9db5ed68854
  patch :DATA

  def install
    ENV.prepend_path "PATH", Formula["python"].opt_libexec/"bin"

    # https://github.com/Homebrew/homebrew-core/pull/1046
    ENV.delete("SDKROOT")
    ENV["LUA_PREFIX"] = HOMEBREW_PREFIX

    # vim doesn't require any Python package, unset PYTHONPATH.
    ENV.delete("PYTHONPATH")

    # We specify HOMEBREW_PREFIX as the prefix to make vim look in the
    # the right place (HOMEBREW_PREFIX/share/vim/{vimrc,vimfiles}) for
    # system vimscript files. We specify the normal installation prefix
    # when calling "make install".
    # Homebrew will use the first suitable Perl & Ruby in your PATH if you
    # build from source. Please don't attempt to hardcode either.
    system "./configure", "--prefix=#{HOMEBREW_PREFIX}",
                          "--mandir=#{man}",
                          "--enable-multibyte",
                          "--with-tlib=ncurses",
                          "--enable-cscope",
                          "--with-compiledby=Homebrew",
                          "--enable-perlinterp",
                          "--enable-rubyinterp",
                          "--enable-python3interp",
                          "--enable-gui=no",
                          "--without-x",
                          "--enable-luainterp",
                          "--with-lua-prefix=#{Formula["lua"].opt_prefix}"
    system "make"
    # Parallel install could miss some symlinks
    # https://github.com/vim/vim/issues/1031
    ENV.deparallelize
    # If stripping the binaries is enabled, vim will segfault with
    # statically-linked interpreters like ruby
    # https://github.com/vim/vim/issues/114
    system "make", "install", "prefix=#{prefix}", "STRIP=#{which "true"}"
    bin.install_symlink "vim" => "vi"
  end

  test do
    (testpath/"commands.vim").write <<~EOS
      :python3 import vim; vim.current.buffer[0] = 'hello python3'
      :wq
    EOS
    system bin/"vim", "-T", "dumb", "-s", "commands.vim", "test.txt"
    assert_equal "hello python3", File.read("test.txt").chomp
  end
end

__END__
diff --git a/src/if_python3.c b/src/if_python3.c
index 02d913492c..59c115dd8d 100644
--- a/src/if_python3.c
+++ b/src/if_python3.c
@@ -34,11 +34,6 @@

 #include <limits.h>

-/* Python.h defines _POSIX_THREADS itself (if needed) */
-#ifdef _POSIX_THREADS
-# undef _POSIX_THREADS
-#endif
-
 #if defined(_WIN32) && defined(HAVE_FCNTL_H)
 # undef HAVE_FCNTL_H
 #endif
