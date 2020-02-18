class Mlpack < Formula
  desc "Scalable C++ machine learning library"
  homepage "https://www.mlpack.org"
  url "https://mlpack.org/files/mlpack-3.2.2.tar.gz"
  sha256 "7aef8c27645c9358262fec9ebba380720a086789d6519d5d1034346412a52ad6"
  revision 2

  bottle do
    cellar :any
    sha256 "4437b48f7bbe575edf093ffc7a0a5892a2408eef1e16d50c2d207d1ebb01df68" => :catalina
    sha256 "6e8f7d1af5e2100b63c1aa13b75a7383616177ee1e5e24d5ab70cc41f47b1691" => :mojave
    sha256 "b42a941aca1aea90c343c10b8db0cd20fb043b411ad6a060e1a1d98fd210bcc1" => :high_sierra
  end

  depends_on "cmake" => :build
  depends_on "doxygen" => :build
  depends_on "pkg-config" => :build
  depends_on "armadillo"
  depends_on "boost"
  depends_on "ensmallen"
  depends_on "graphviz"

  resource "stb" do
    url "https://github.com/nothings/stb/archive/f67165c2bb2af3060ecae7d20d6f731173485ad0.tar.gz"
    sha256 "ad5d34b385494cf68c52fad5762d00181c0c6d4787988fc75f17295c3c726bf8"
  end

  def install
    resource("stb").stage do
      (include/"stb").install Dir["*.h"]
    end
    cmake_args = std_cmake_args + %W[
      -DDEBUG=OFF
      -DPROFILE=OFF
      -DDOWNLOAD_STB_IMAGE=OFF
      -DARMADILLO_INCLUDE_DIR=#{Formula["armadillo"].opt_include}
      -DENSMALLEN_INCLUDE_DIR=#{Formula["ensmallen"].opt_include}
      -DARMADILLO_LIBRARY=#{Formula["armadillo"].opt_lib}/libarmadillo.dylib
      -DSTB_IMAGE_INCLUDE_DIR=#{(include/"stb")}
    ]
    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
    doc.install Dir["doc/*"]
    pkgshare.install "src/mlpack/tests" # Includes test data.
  end

  test do
    cd testpath do
      system "#{bin}/mlpack_knn",
        "-r", "#{pkgshare}/tests/data/GroupLensSmall.csv",
        "-n", "neighbors.csv",
        "-d", "distances.csv",
        "-k", "5", "-v"
    end

    (testpath / "test.cpp").write <<-EOS
      #include <mlpack/core.hpp>

      using namespace mlpack;

      int main(int argc, char** argv) {
        Log::Debug << "Compiled with debugging symbols." << std::endl;
        Log::Info << "Some test informational output." << std::endl;
        Log::Warn << "A false alarm!" << std::endl;
      }
    EOS
    cxx_with_flags = ENV.cxx.split + ["test.cpp",
                                      "-std=c++11",
                                      "-I#{include}",
                                      "-I#{Formula["armadillo"].opt_lib}/libarmadillo",
                                      "-L#{lib}", "-lmlpack",
                                      "-o", "test"]
    system *cxx_with_flags
    system "./test", "--verbose"
  end
end
