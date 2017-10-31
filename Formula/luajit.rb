class Luajit < Formula
  desc "Just-In-Time Compiler (JIT) for the Lua programming language"
  homepage "https://luajit.org/luajit.html"
  url "https://luajit.org/download/LuaJIT-2.0.5.tar.gz"
  sha256 "874b1f8297c697821f561f9b73b57ffd419ed8f4278c82e05b48806d30c1e979"

  bottle do
    rebuild 1
    sha256 "0b1f267968a2f56a519cbe8f736918ab86bda34ab76fb9dd5706823fb59d291e" => :high_sierra
    sha256 "a36f3e7674d2e4dcbccdaa096856ef5f133b4aa8351f42492414c04803c40493" => :sierra
    sha256 "01426fc484a1cc4f622a5cac41cc92ae4a3575bfda47a9f6601df5513fdea37e" => :el_capitan
  end

  devel do
    url "https://luajit.org/download/LuaJIT-2.1.0-beta3.tar.gz"
    sha256 "1ad2e34b111c802f9d0cdf019e986909123237a28c746b21295b63c9e785d9c3"
    option "with-gc64", "Build with 64-bit support"
  end

  head do
    url "https://luajit.org/git/luajit-2.0.git", :branch => "v2.1"
    option "with-gc64", "Build with 64-bit support"
  end

  deprecated_option "enable-debug" => "with-debug"

  option "with-debug", "Build with debugging symbols"
  option "with-52compat", "Build with additional Lua 5.2 compatibility"

  def install
    # 1 - Override the hardcoded gcc.
    # 2 - Remove the "-march=i686" so we can set the march in cflags.
    # Both changes should persist and were discussed upstream.
    inreplace "src/Makefile" do |f|
      f.change_make_var! "CC", ENV.cc
      f.change_make_var! "CCOPT_x86", ""
    end

    ENV.O2 # Respect the developer's choice.

    args = %W[PREFIX=#{prefix}]

    cflags = ""
    cflags += "-DLUAJIT_ENABLE_LUA52COMPAT " if build.with? "52compat"
    cflags += "-DLUAJIT_ENABLE_GC64" if build.with? "gc64"

    args << "XCFLAGS=#{cflags}" if cflags != ""

    # This doesn't yet work under superenv because it removes "-g"
    args << "CCDEBUG=-g" if build.with? "debug"

    # The development branch of LuaJIT normally does not install "luajit".
    args << "INSTALL_TNAME=luajit" if build.devel?

    system "make", "amalg", *args
    system "make", "install", *args

    # LuaJIT doesn't automatically symlink unversioned libraries:
    # https://github.com/Homebrew/homebrew/issues/45854.
    lib.install_symlink lib/"libluajit-5.1.dylib" => "libluajit.dylib"
    lib.install_symlink lib/"libluajit-5.1.a" => "libluajit.a"

    # Fix path in pkg-config so modules are installed
    # to permanent location rather than inside the Cellar.
    inreplace lib/"pkgconfig/luajit.pc" do |s|
      s.gsub! "INSTALL_LMOD=${prefix}/share/lua/${abiver}",
              "INSTALL_LMOD=#{HOMEBREW_PREFIX}/share/lua/${abiver}"
      s.gsub! "INSTALL_CMOD=${prefix}/${multilib}/lua/${abiver}",
              "INSTALL_CMOD=#{HOMEBREW_PREFIX}/${multilib}/lua/${abiver}"
      if build.without? "gc64"
        s.gsub! "Libs:",
                "Libs: -pagezero_size 10000 -image_base 100000000"
      end
    end

    # Having an empty Lua dir in lib/share can mess with other Homebrew Luas.
    %W[#{lib}/lua #{share}/lua].each { |d| rm_rf d }
  end

  test do
    system "#{bin}/luajit", "-e", <<~EOS
      local ffi = require("ffi")
      ffi.cdef("int printf(const char *fmt, ...);")
      ffi.C.printf("Hello %s!\\n", "#{ENV["USER"]}")
    EOS
  end
end
