class Hyperscan < Formula
  desc "High-performance regular expression matching library"
  homepage "https://www.hyperscan.io/"
  url "https://github.com/intel/hyperscan/archive/v5.0.0.tar.gz"
  sha256 "f2bdebff62a2fc0b974b309da7be4959869fb7cababe1169b7693cfd672c2fe0"

  bottle do
    cellar :any
    sha256 "7114cdf8a7e154d861a21a9a3dab22639875ed40e5398021bd73987a8ef263b9" => :high_sierra
    sha256 "cd7714c9f44d58be98bdc64d3294bcd40cfb070bd7ce6af2c93359d33d4d1285" => :sierra
    sha256 "769a4578b1776d344622e8a3d45e48d927b67fea7cda7dbe94160d39abae8807" => :el_capitan
  end

  option "with-debug", "Build with debug symbols"

  depends_on "python@2" => :build
  depends_on "boost" => :build
  depends_on "ragel" => :build
  depends_on "cmake" => :build
  depends_on "pkg-config" => :build

  def install
    mkdir "build" do
      args = std_cmake_args << "-DBUILD_STATIC_AND_SHARED=on"

      if build.with? "debug"
        args -= %w[
          -DCMAKE_BUILD_TYPE=Release
          -DCMAKE_C_FLAGS_RELEASE=-DNDEBUG
          -DCMAKE_CXX_FLAGS_RELEASE=-DNDEBUG
        ]
        args += %w[
          -DCMAKE_BUILD_TYPE=Debug
          -DDEBUG_OUTPUT=on
        ]
      end

      system "cmake", "..", *args
      system "make", "install"
    end
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <stdio.h>
      #include <hs/hs.h>
      int main()
      {
        printf("hyperscan v%s", hs_version());
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lhs", "-o", "test"
    system "./test"
  end
end
