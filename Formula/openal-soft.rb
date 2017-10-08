class OpenalSoft < Formula
  desc "Implementation of the OpenAL 3D audio API"
  homepage "http://kcat.strangesoft.net/openal.html"
  url "https://github.com/kcat/openal-soft/archive/openal-soft-1.18.2.tar.gz"
  sha256 "a598241d1af2e90c25a1b91da4c9ddc0e7cb6a4b5f1477fc680d139c57cd38cc"
  head "http://repo.or.cz/openal-soft.git"

  bottle do
    cellar :any
    sha256 "e166ede768b1bdef14b5ae85043e05b34ac6c53e57bb6f73b4fc4b0954f8aab4" => :high_sierra
    sha256 "24dd59b5106fb9d6884b20aaf0c79691c7d0eda8e13ba5b943ba5bc49a794787" => :sierra
    sha256 "a7946da113c242708cf9aa80c12cc2beedf555fd6a9aed5e7656a983a80e1df4" => :el_capitan
  end

  keg_only :provided_by_osx, "macOS provides OpenAL.framework"

  depends_on "pkg-config" => :build
  depends_on "cmake" => :build
  depends_on "portaudio" => :optional
  depends_on "fluid-synth" => :optional
  depends_on "jack" => :optional

  # clang 4.2's support for alignas is incomplete
  fails_with(:clang) { build 425 }

  def install
    #  See: https://github.com/kcat/openal-soft/issues/153
    ENV.append "LDFLAGS", "-Wl,-rpath,#{opt_lib}"

    # Please don't reenable example building. See:
    # https://github.com/Homebrew/homebrew/issues/38274
    args = std_cmake_args
    args << "-DALSOFT_EXAMPLES=OFF" <<"-DALSOFT_BACKEND_PULSEAUDIO=OFF"

    args << "-DALSOFT_BACKEND_PORTAUDIO=OFF" if build.without? "portaudio"
    args << "-DALSOFT_MIDI_FLUIDSYNTH=OFF" if build.without? "fluid-synth"
    args << "-DALSOFT_BACKEND_JACK=OFF" if build.without? "jack"

    system "cmake", ".", *args
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include "AL/al.h"
      #include "AL/alc.h"
      int main() {
        ALCdevice *device;
        device = alcOpenDevice(0);
        alcCloseDevice(device);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lopenal"
  end
end
