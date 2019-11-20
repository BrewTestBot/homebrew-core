class Reminiscence < Formula
  desc "Flashback engine reimplementation"
  homepage "http://cyxdown.free.fr/reminiscence/"
  url "http://cyxdown.free.fr/reminiscence/REminiscence-0.4.5.tar.bz2"
  sha256 "108ec26b71539a0697eff97498c31a26a10278892649584531732a0df0472abf"

  bottle do
    cellar :any
    sha256 "e9aae2075cd05b555dca8b412155702693ba8316f608a4322390981c9ac9257d" => :catalina
    sha256 "cc5296f5f2da8c789307dc8416e87359f3436297aab27ccf708b9f49fafcc363" => :mojave
    sha256 "ac5c1018c11c7050e248722bf6956dc6cd82a68eb7eb9db9917743815ffe027d" => :high_sierra
    sha256 "5c82408dca2c80f1f11e433a94f91b9689adf701d597c0c7e8a729c54373ce41" => :sierra
    sha256 "f8f3f8688125d6b24fc99df7f4d8acf29140b0fdf637dcb2d540b02600105355" => :el_capitan
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build
  depends_on "libmodplug"
  depends_on "libogg"
  depends_on "sdl2"

  resource "tremor" do
    url "https://git.xiph.org/tremor.git",
        :revision => "7c30a66346199f3f09017a09567c6c8a3a0eedc8"
  end

  def install
    resource("tremor").stage do
      system "./autogen.sh", "--disable-dependency-tracking",
                             "--disable-silent-rules",
                             "--prefix=#{libexec}",
                             "--disable-static"
      system "make", "install"
    end

    # fix for files missing from archive, reported upstream via email
    inreplace "Makefile" do |s|
      s.gsub! "-DUSE_STATIC_SCALER", ""
      s.gsub! "SCALERS :=", "#SCALERS :="
    end

    ENV.prepend "CPPFLAGS", "-I#{libexec}/include"
    ENV.prepend "LDFLAGS", "-L#{libexec}/lib"

    system "make"
    bin.install "rs" => "reminiscence"
  end

  test do
    system bin/"reminiscence", "--help"
  end
end
