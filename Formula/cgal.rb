class Cgal < Formula
  desc "Computational Geometry Algorithms Library"
  homepage "https://www.cgal.org/"
  url "https://github.com/CGAL/cgal/releases/download/releases%2FCGAL-5.0.2/CGAL-5.0.2.tar.xz"
  sha256 "bb3594ba390735404f0972ece301f369b1ff12646ad25e48056b4d49c976e1fa"

  bottle do
    cellar :any_skip_relocation
    rebuild 1
    sha256 "f8a09bd370cd1cb0e775961425772be6705e8dd91fefca76a655e5fadeddb0a1" => :catalina
    sha256 "f8a09bd370cd1cb0e775961425772be6705e8dd91fefca76a655e5fadeddb0a1" => :mojave
    sha256 "f8a09bd370cd1cb0e775961425772be6705e8dd91fefca76a655e5fadeddb0a1" => :high_sierra
  end

  depends_on "cmake" => [:build, :test]
  depends_on "boost"
  depends_on "eigen"
  depends_on "gmp"
  depends_on "mpfr"

  def install
    args = std_cmake_args + %W[
      -DCMAKE_CXX_FLAGS='-std=c++14'
      -DWITH_Eigen3=ON
      -DWITH_CGAL_Qt5=OFF
      -DWITH_CGAL_ImageIO=OFF
    ]
    system "cmake", ".", *args

    # Manually edit the file that define CGAL_ROOT so it can work with cgal-qt5
    # The goal is to make it work at least when cgal and cgal-qt5 are linked
    rm buildpath/"config/CGALConfig-installation-dirs.cmake"
    (buildpath/"config/CGALConfig-installation-dirs.cmake").write <<~EOS
      if( EXISTS #{HOMEBREW_PREFIX}/include/CGAL/AABB_traits.h)
        set(CGAL_ROOT #{HOMEBREW_PREFIX}/)
      else()
        set(CGAL_ROOT #{prefix})
      endif()
    EOS
    system "make", "install"
  end

  test do
    # https://doc.cgal.org/latest/Algebraic_foundations/Algebraic_foundations_2interoperable_8cpp-example.html
    (testpath/"surprise.cpp").write <<~EOS
      #include <CGAL/basic.h>
      #include <CGAL/Coercion_traits.h>
      #include <CGAL/IO/io.h>
      template <typename A, typename B>
      typename CGAL::Coercion_traits<A,B>::Type
      binary_func(const A& a , const B& b){
          typedef CGAL::Coercion_traits<A,B> CT;
          CGAL_static_assertion((CT::Are_explicit_interoperable::value));
          typename CT::Cast cast;
          return cast(a)*cast(b);
      }
      int main(){
          std::cout<< binary_func(double(3), int(5)) << std::endl;
          std::cout<< binary_func(int(3), double(5)) << std::endl;
          return 0;
      }
    EOS
    (testpath/"CMakeLists.txt").write <<~EOS
      cmake_minimum_required(VERSION 3.1...3.13)
      find_package(CGAL)
      add_executable(surprise surprise.cpp)
      target_link_libraries(surprise PRIVATE CGAL::CGAL)
    EOS
    system "cmake", "-L", "-DCMAKE_BUILD_RPATH=#{HOMEBREW_PREFIX}/lib", "-DCMAKE_PREFIX_PATH=#{prefix}", "."
    system "cmake", "--build", ".", "-v"
    assert_equal "15\n15", shell_output("./surprise").chomp
  end
end
