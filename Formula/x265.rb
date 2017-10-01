class X265 < Formula
  desc "H.265/HEVC encoder"
  homepage "http://x265.org"
  url "https://bitbucket.org/multicoreware/x265/downloads/x265_2.5.tar.gz"
  sha256 "2e53259b504a7edb9b21b9800163b1ff4c90e60c74e23e7001d423c69c5d3d17"

  head "https://bitbucket.org/multicoreware/x265", :using => :hg

  bottle do
    cellar :any
    rebuild 1
    sha256 "82626e8656b1135bed236f9eaa205449753f32b7d83acc4b4b51fced9e90256e" => :high_sierra
    sha256 "a5630bc95c2995ef83bd121478382517484321ccb4b339ee429722ee6e262231" => :sierra
    sha256 "5791023d550c3e1021f0cc3f442686cecdc11adf1ecd75a94ea62f88db71b6bd" => :el_capitan
  end

  option "with-10-bit", "Include 10-bit support (default: off)"
  option "with-12-bit", "Include 12-bit support (default: off)"

  deprecated_option "16-bit" => "with-10-bit"
  deprecated_option "with-16-bit" => "with-10-bit"

  depends_on "yasm" => :build
  depends_on "cmake" => :build
  depends_on :macos => :lion

  def install
    # Build based off script at build/linux/multilib.sh
    args = std_cmake_args
    eight_bit_args = Array.new(args)
    extra_libs = []
    mkdir "8bit"

    if build.with? "10-bit"
      mkdir "10bit"
      Dir.chdir "10bit" do
        system "cmake", "../source", "-DHIGH_BIT_DEPTH=ON", "-DEXPORT_C_API=OFF", "-DENABLE_SHARED=OFF", "-DENABLE_CLI=OFF", *args
        system "make"
        mv "libx265.a", "../8bit/libx265_main10.a"
      end
      extra_libs << "x265_main10.a"
      eight_bit_args << "-DLINKED_10BIT=ON"
    end

    if build.with? "12-bit"
      mkdir "12bit"
      Dir.chdir "12bit" do
        system "cmake", "../source", "-DHIGH_BIT_DEPTH=ON", "-DEXPORT_C_API=OFF", "-DENABLE_SHARED=OFF", "-DENABLE_CLI=OFF", "-DMAIN12=ON", *args
        system "make"
        mv "libx265.a", "../8bit/libx265_main12.a"
      end
      extra_libs << "x265_main12.a"
      eight_bit_args << "-DLINKED_12BIT=ON"
    end

    if extra_libs.count.positive?
      eight_bit_args << "-DEXTRA_LIB=#{extra_libs.join(";")}"
      eight_bit_args << "-DEXTRA_LINK_FLAGS=-L."
    end

    Dir.chdir "8bit" do
      system "cmake", "../source", *eight_bit_args
      if extra_libs.count.positive?
        system "make"
        mv "libx265.a", "libx265_main.a"
        system "libtool", "-static", "-o", "libx265.a", "libx265_main.a", *(extra_libs.map { |lib| "lib#{lib}" })
      end
      system "make", "install"
    end
  end

  test do
    yuv_path = testpath/"raw.yuv"
    x265_path = testpath/"x265.265"
    yuv_path.binwrite "\xCO\xFF\xEE" * 3200
    system bin/"x265", "--input-res", "80x80", "--fps", "1", yuv_path, x265_path
    header = "AAAAAUABDAH//w=="
    assert_equal header.unpack("m"), [x265_path.read(10)]
  end
end
