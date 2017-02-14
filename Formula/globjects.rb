class Globjects < Formula
  desc "C++ library strictly wrapping OpenGL objects"
  homepage "https://github.com/cginternals/globjects"
  url "https://github.com/cginternals/globjects/archive/v1.0.0.tar.gz"
  sha256 "be2f95b4e98eef61a57925985735af266fef667eec63a39f65def5d5d808a30a"
  head "https://github.com/cginternals/globjects.git"

  depends_on "cmake" => :build
  depends_on "glm" => :build
  depends_on "glbinding"

  needs :cxx11
  
  def install
    ENV.cxx11
    system "cmake", ".", "-Dglbinding_DIR=#{Formula["glbinding"].opt_prefix}", *std_cmake_args
    system "cmake", "--build", ".", "--target", "install"
  end
  
  test do
    (testpath/"test.cpp").write <<-EOS.undent
      #include <globjects/globjects.h>
      int main(void)
      {
        globjects::init();
      }
      EOS
    system ENV.cxx, "-o", "test", "test.cpp", "-std=c++11", "-stdlib=libc++",
           "-I#{include}/globjects", "-I#{Formula["glm"].opt_prefix}/include/glm", "-I#{lib}/globjects",
           "-lglobjects", "-lglbinding", *ENV.cflags.to_s.split
    system "./test"
  end
end
