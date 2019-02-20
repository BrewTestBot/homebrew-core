class ApacheArrow < Formula
  desc "Columnar in-memory analytics layer designed to accelerate big data"
  homepage "https://arrow.apache.org/"
  url "https://www.apache.org/dyn/closer.cgi?path=arrow/arrow-0.12.0/apache-arrow-0.12.0.tar.gz"
  sha256 "34dae7e4dde9274e9a52610683e78a80f3ca312258ad9e9f2c0973cf44247a98"
  head "https://github.com/apache/arrow.git"

  bottle do
    cellar :any
    rebuild 1
    sha256 "cf6205610edc980a6e9898d2f9060788bc8c268e342711687459869e7c2b1476" => :mojave
    sha256 "7d549ddf18e2e78e2fcd8599f5e266dae9d3f1cd42ce67389897fa81013e8d55" => :high_sierra
    sha256 "79228e5e8661b4011aad194861aadee951535d216172f0b95f7d9e082fa13fe3" => :sierra
  end

  depends_on "autoconf" => :build
  depends_on "cmake" => :build
  depends_on "boost"
  depends_on "flatbuffers"
  depends_on "lz4"
  depends_on "numpy"
  depends_on "protobuf"
  depends_on "python"
  depends_on "snappy"
  depends_on "thrift"
  depends_on "zstd"

  def install
    ENV.cxx11
    args = %W[
      -DARROW_ORC=ON
      -DARROW_PARQUET=ON
      -DARROW_PLASMA=ON
      -DARROW_PROTOBUF_USE_SHARED=ON
      -DARROW_PYTHON=ON
      -DFLATBUFFERS_HOME=#{Formula["flatbuffers"].prefix}
      -DLZ4_HOME=#{Formula["lz4"].prefix}
      -DPROTOBUF_HOME=#{Formula["protobuf"].prefix}
      -DPYTHON_EXECUTABLE=#{Formula["python"].bin/"python3"}
      -DSNAPPY_HOME=#{Formula["snappy"].prefix}
      -DTHRIFT_HOME=#{Formula["thrift"].prefix}
      -DZSTD_HOME=#{Formula["zstd"].prefix}
    ]

    mkdir "build"
    cd "build" do
      system "cmake", "../cpp", *std_cmake_args, *args
      system "make"
      system "make", "install"
    end
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include "arrow/api.h"
      int main(void) {
        arrow::int64();
        return 0;
      }
    EOS
    system ENV.cxx, "test.cpp", "-std=c++11", "-I#{include}", "-L#{lib}", "-larrow", "-o", "test"
    system "./test"
  end
end
