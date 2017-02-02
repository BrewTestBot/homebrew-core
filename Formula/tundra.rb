class Tundra < Formula
  desc "Code build system that tries to be fast for incremental builds"
  homepage "https://github.com/deplinenoise/tundra"
  url "https://github.com/deplinenoise/tundra/archive/v2.0.tar.gz"
  sha256 "0d9f2b756959db76619aab563b412fa9e8a8bbf6fe0fc44836a725febb2c7662"

  def install
    system "make"
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    (testpath/"test.c").write <<-'EOS_SRC'.undent
      #include <stdio.h>
      int main() {
        printf("Hello World\n");
        return 0;
      }
    EOS_SRC
    (testpath/"tundra.lua").write <<-'EOS_CONFIG'.undent
      Build {
        Units = function()
          local test = Program {
            Name = "test",
            Sources = { "test.c" },
          }
          Default(test)
        end,
        Configs = {
          {
            Name = "macosx-clang",
            DefaultOnHost = "macosx",
            Tools = { "clang-osx" },
          },
        },
      }
    EOS_CONFIG
    system bin/"tundra2"
    system "./t2-output/macosx-clang-debug-default/test"
  end
end
