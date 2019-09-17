class VulkanHeaders < Formula
  desc "Vulkan Header files and API registry"
  homepage "https://github.com/KhronosGroup/Vulkan-Headers"
  url "https://github.com/KhronosGroup/Vulkan-Headers/archive/v1.1.123.tar.gz"
  sha256 "aa58ddcf972f05d26bdfa50ac689022b77baf101317258ac146393ef47741581"

  bottle do
    cellar :any_skip_relocation
    sha256 "6cf5d1389e54859934289bb5ab5066950717c2b856d885605350b21db00e4cd5" => :mojave
    sha256 "6cf5d1389e54859934289bb5ab5066950717c2b856d885605350b21db00e4cd5" => :high_sierra
    sha256 "b3af602b3db8b322a22c42726ca6f2837ff6cb5d8728646fe982e688c4c1a5ed" => :sierra
  end

  depends_on "cmake" => :build

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <stdio.h>
      #include <vulkan/vulkan_core.h>

      int main() {
        printf("vulkan version %d", VK_VERSION_1_0);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-o", "test"
    system "./test"
  end
end
