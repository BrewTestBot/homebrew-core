class Libzt < Formula
  desc "Encrypted P2P networking library for applications"
  homepage "https://www.zerotier.com"

  url "https://github.com/zerotier/libzt.git",
    :tag   => "1.3.0-13-g9dbcc8e"

  depends_on "cmake" => :build

  def install
    system "git", "-C", "ext/lwip", "apply", "../lwip.patch"
    system "git", "-C", "ext/lwip-contrib", "apply", "../lwip-contrib.patch"
    system "git", "-C", "ext/ZeroTierOne", "apply", "../ZeroTierOne.patch"
    system "cmake", ".", *std_cmake_args
    system "cmake", "--build", "."
    system "make", "install"
    prefix.install "LICENSE.GPL-3" => "LICENSE"
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <cstdlib>
      #include <ZeroTier.h>
      int main()
      {
        return zts_socket(0,0,0) != -2;
      }
    EOS
    system ENV.cxx, "-v", "test.cpp", "-o", "test", "-L#{lib}", "-lzt"
    system "./test"
  end
end
