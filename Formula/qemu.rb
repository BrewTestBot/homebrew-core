class Qemu < Formula
  desc "x86 and PowerPC Emulator"
  homepage "http://www.qemu.org/"
  url "http://download.qemu.org/qemu-2.9.0.tar.bz2"
  sha256 "00bfb217b1bb03c7a6c3261b819cfccbfb5a58e3e2ceff546327d271773c6c14"

  head "git://git.qemu-project.org/qemu.git"

  bottle do
    rebuild 1
    sha256 "3387a798e821b5e12aa6bc0974a3e908efb199883a8a291019da3e67a62b2558" => :sierra
    sha256 "405bbef1c02e8cfc6f72c0e40b3fdfad3b40bb2bb6c7d19e55ee5ca39fd1fa5c" => :el_capitan
    sha256 "df433e6813f816cd4ae75a2aa9b31353c1800c4b43074d8da0808775497e9171" => :yosemite
  end

  depends_on "pkg-config" => :build
  depends_on "libtool" => :build
  depends_on "jpeg"
  depends_on "gnutls"
  depends_on "glib"
  depends_on "pixman"
  depends_on "libpng" => :recommended
  depends_on "vde" => :optional
  depends_on "sdl2" => :optional
  depends_on "gtk+" => :optional
  depends_on "libssh2" => :optional

  deprecated_option "with-sdl" => "with-sdl2"

  fails_with :gcc_4_0 do
    cause "qemu requires a compiler with support for the __thread specifier"
  end

  fails_with :gcc do
    cause "qemu requires a compiler with support for the __thread specifier"
  end

  # 3.2MB working disc-image file hosted on upstream's servers for people to use to test qemu functionality.
  resource "armtest" do
    url "http://download.qemu.org/arm-test-0.2.tar.gz"
    sha256 "4b4c2dce4c055f0a2adb93d571987a3d40c96c6cbfd9244d19b9708ce5aea454"
  end

  def install
    ENV["LIBTOOL"] = "glibtool"

    # Fixes "dyld: lazy symbol binding failed: Symbol not found: _clock_gettime"
    if MacOS.version == "10.11" && MacOS::Xcode.installed? && MacOS::Xcode.version >= "8.0"
      inreplace %w[hw/i386/kvm/i8254.c include/qemu/timer.h linux-user/strace.c
                   roms/skiboot/external/pflash/progress.c
                   roms/u-boot/arch/sandbox/cpu/os.c ui/spice-display.c
                   util/qemu-timer-common.c], "CLOCK_MONOTONIC", "NOT_A_SYMBOL"
    end

    args = %W[
      --prefix=#{prefix}
      --cc=#{ENV.cc}
      --host-cc=#{ENV.cc}
      --disable-bsd-user
      --disable-guest-agent
    ]

    # Cocoa and SDL2/GTK+ UIs cannot both be enabled at once.
    if build.with?("sdl2") || build.with?("gtk+")
      args << "--disable-cocoa"
    else
      args << "--enable-cocoa"
    end

    args << (build.with?("vde") ? "--enable-vde" : "--disable-vde")
    args << (build.with?("sdl2") ? "--enable-sdl" : "--disable-sdl")
    args << (build.with?("gtk+") ? "--enable-gtk" : "--disable-gtk")
    args << (build.with?("libssh2") ? "--enable-libssh2" : "--disable-libssh2")

    system "./configure", *args
    system "make", "V=1", "install"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/qemu-system-i386 --version")
    resource("armtest").stage testpath
    assert_match "file format: raw", shell_output("#{bin}/qemu-img info arm_root.img")
  end
end
