class Audacious < Formula
  desc "Free and advanced audio player based on GTK+"
  homepage "http://audacious-media-player.org"

  stable do
    url "http://distfiles.audacious-media-player.org/audacious-3.9.tar.bz2"
    sha256 "2d8044673ac786d71b08004f190bbca368258bf60e6602ffc0d9622835ccb05e"

    resource "plugins" do
      url "http://distfiles.audacious-media-player.org/audacious-plugins-3.9.tar.bz2"
      sha256 "8bf7f21089cb3406968cc9c71307774aee7100ec4607f28f63cf5690d5c927b8"

      # Fixes "info_bar.cc:258:21: error: no viable overloaded '='"
      # Upstream PR from 11 Dec 2017 "qtui: fix build with Qt 5.10"
      patch do
        url "https://github.com/audacious-media-player/audacious-plugins/pull/62.patch?full_index=1"
        sha256 "055e11096de7a8b695959b0d5f69a7f84630764f7abd7ec7b4dc3f14a719d9de"
      end
    end
  end

  bottle do
    rebuild 1
    sha256 "cf82e2565e32f539cdef9532b711c3b9137db103bb93747284e763618609d556" => :high_sierra
    sha256 "3e5f394e51b265a687814c1485fa49e82619cf5d37c69cfabda64375b13debb6" => :sierra
    sha256 "1eb048dc23b759bd3efca44b5cb54aa2c3870bcbe29a4c3c7bb920777c26c31d" => :el_capitan
  end

  head do
    url "https://github.com/audacious-media-player/audacious.git"

    resource "plugins" do
      url "https://github.com/audacious-media-player/audacious-plugins.git"
    end

    depends_on "automake" => :build
    depends_on "autoconf" => :build
    depends_on "libtool" => :build
  end

  depends_on "gettext" => :build
  depends_on "make" => :build
  depends_on "pkg-config" => :build
  depends_on "faad2"
  depends_on "ffmpeg"
  depends_on "flac"
  depends_on "fluid-synth"
  depends_on "glib"
  depends_on "lame"
  depends_on "libbs2b"
  depends_on "libcue"
  depends_on "libnotify"
  depends_on "libsamplerate"
  depends_on "libsoxr"
  depends_on "libvorbis"
  depends_on "mpg123"
  depends_on "neon"
  depends_on "sdl2"
  depends_on "wavpack"
  depends_on "python" if MacOS.version <= :snow_leopard
  depends_on "qt" => :recommended
  depends_on "gtk+" => :optional
  depends_on "jack" => :optional
  depends_on "libmms" => :optional
  depends_on "libmodplug" => :optional

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-coreaudio
      --enable-mac-media-keys
      --disable-mpris2
    ]

    args << "--enable-qt" if build.with? "qt"
    args << "--disable-gtk" if build.without? "gtk+"

    system "./autogen.sh" if build.head?
    system "./configure", *args
    system "make"
    system "make", "install"

    resource("plugins").stage do
      ENV.prepend_path "PKG_CONFIG_PATH", "#{lib}/pkgconfig"

      system "./autogen.sh" if build.head?

      system "./configure", *args
      system "make"
      system "make", "install"
    end
  end

  def caveats; <<~EOS
    audtool does not work due to a broken dbus implementation on macOS, so is not built
    coreaudio output has been disabled as it does not work (Fails to set audio unit input property.)
    GTK+ gui is not built by default as the QT gui has better integration with macOS, and when built, the gtk gui takes precedence
    EOS
  end

  test do
    system bin/"audacious", "--help"
  end
end
