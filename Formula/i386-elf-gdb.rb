class I386ElfGdb < Formula
  desc "The GNU Project debugger for i386-elf cross development"
  homepage "https://www.gnu.org/software/gdb/"
  url "https://ftp.gnu.org/gnu/gdb/gdb-8.2.tar.xz"
  sha256 "c3a441a29c7c89720b734e5a9c6289c0a06be7e0c76ef538f7bbcef389347c39"

  depends_on "i386-elf-binutils"
  depends_on "i386-elf-gcc"

  def install
    mkdir "i386-elf-gdb-build" do
      system "../configure", "--target=i386-elf",
                             "--prefix=#{prefix}",
                             "--with-gmp=#{prefix}",
                             "--with-libelf=#{prefix}",
                             "--with-build-libsubdir=#{prefix}"
      system "make"
      system "make", "install"
    end
  end

  test do
    system "#{bin}/i386-elf-gdb", "#{bin}/i386-elf-gdb", "-configuration"
  end
end
