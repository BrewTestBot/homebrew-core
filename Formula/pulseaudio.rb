class Pulseaudio < Formula
  desc "Sound system for POSIX OSes"
  homepage "https://wiki.freedesktop.org/www/Software/PulseAudio/"
  url "https://www.freedesktop.org/software/pulseaudio/releases/pulseaudio-10.99.1.tar.xz"
  sha256 "c9791844569d8d0adb468c183d0d9fb6ac12b9db34a4a078a7773c8bac993f32"

  bottle do
    rebuild 1
    sha256 "ab24c774415dfb08718b7c0db28a132053dad9708cc8d0fcb8f7f1250900ff26" => :sierra
    sha256 "daead5ebc889933d86cad2076c8f34224b9b6cb4a8d1993d46c61262e22a6e9d" => :el_capitan
    sha256 "26bb6340edca4c577c23ce76373ce0ba2d0266d9bb5656ad58a8ff3063080ea8" => :yosemite
  end

  head do
    url "https://anongit.freedesktop.org/git/pulseaudio/pulseaudio.git"

    depends_on "automake" => :build
    depends_on "autoconf" => :build
    depends_on "intltool" => :build
    depends_on "gettext" => :build
  end

  option "with-nls", "Build with native language support"

  deprecated_option "without-speex" => "without-speexdsp"

  depends_on "pkg-config" => :build

  if build.with? "nls"
    depends_on "intltool" => :build
    depends_on "gettext" => :build
  end

  depends_on "libtool" => :run
  depends_on "json-c"
  depends_on "libsndfile"
  depends_on "libsoxr"
  depends_on "openssl"
  depends_on "speexdsp" => :recommended
  depends_on "glib" => :optional
  depends_on "gconf" => :optional
  depends_on "gtk+3" => :optional
  depends_on "jack" => :optional

  fails_with :clang do
    build 421
    cause "error: thread-local storage is unsupported for the current target"
  end

  def install
    args = %W[
      --disable-dependency-tracking
      --disable-silent-rules
      --prefix=#{prefix}
      --enable-coreaudio-output
      --disable-neon-opt
      --with-mac-sysroot=#{MacOS.sdk_path}
      --with-mac-version-min=#{MacOS.version}
      --disable-x11
    ]

    args << "--disable-nls" if build.without? "nls"

    if build.head?
      # autogen.sh runs bootstrap.sh then ./configure
      system "./autogen.sh", *args
    else
      system "./configure", *args
    end
    system "make", "install"
  end

  plist_options :manual => "pulseaudio"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_bin}/pulseaudio</string>
        <string>--start</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
    </dict>
    </plist>
    EOS
  end

  test do
    assert_match "module-sine", shell_output("#{bin}/pulseaudio --dump-modules")
  end
end
