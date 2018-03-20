class Parallelstl < Formula
  desc "C++ standard library algorithms with support for execution policies"
  homepage "https://github.com/intel/parallelstl"
  url "https://github.com/intel/parallelstl/archive/20171127.tar.gz"
  sha256 "4d92881984fc476d382454c60f3d10f79605b54206d8fb332fd3287906163dc8"

  bottle do
    cellar :any_skip_relocation
    sha256 "dbbcb3b7bf0509e91e0300cc621d367cb5db9037de587380f656e8b4c827a75a" => :high_sierra
    sha256 "7c7eecc3c568ea8235b71e7f8a84d36178b8ec70f2606bc119e0ca954a08e2e9" => :sierra
    sha256 "dbbcb3b7bf0509e91e0300cc621d367cb5db9037de587380f656e8b4c827a75a" => :el_capitan
  end

  depends_on "tbb"

  def install
    include.install Dir["include/*"]
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <pstl/execution>
      #include <pstl/algorithm>
      #include <array>
      #include <assert.h>

      int main() {
        std::array<int, 10> arr {{5,2,3,1,4,9,7,0,8,6}};
        std::sort(std::execution::par_unseq, arr.begin(), arr.end());
        for(int i=0; i<10; i++)
          assert(i==arr.at(i));
        return 0;
      }
    EOS
    system ENV.cxx, "-std=c++11", "test.cpp", "-I#{include}", "-ltbb", "-o", "test"
    system "./test"
  end
end
