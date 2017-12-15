class Inspectrum < Formula
  desc "Offline radio signal analyser"
  homepage "https://github.com/miek/inspectrum"
  url "https://github.com/miek/inspectrum/archive/v0.2.tar.gz"
  sha256 "50b7db9b86208f414c387700a358eb58364094f3e8a4985f586f4f815645898a"
  head "http://github.com/miek/inspectrum.git"

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "fftw"
  depends_on "liquid-dsp"
  depends_on "qt"

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    assert_equal "Usage: inspectrum [options] file\nspectrum viewer\n\nOptions:\n  -h, --help       Displays this help.\n  -r, --rate <Hz>  Set sample rate.\n\nArguments:\n  file             File to view.", shell_output("#{bin}/inspectrum -h").strip
  end
end
