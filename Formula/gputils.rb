class Gputils < Formula
  desc "GNU PIC Utilities"
  homepage "http://gputils.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/gputils/gputils/1.5.0/gputils-1.5.0.tar.gz"
  sha256 "f6a517c186b991f504be5e4585316871d5950568257885d37487bb368dc76227"

  bottle do
    sha256 "32a73229f86fc8a3bfbbd4582f435c9c92f0b7335e523f3b377d2528631b42b8" => :el_capitan
    sha256 "169a9bcc46bc5e57c7fe9c688ae7bd7f9afc157a222948179133a47d6d2038b4" => :yosemite
    sha256 "6d085798dce7be27385f28b97893d4bb3f44b0d02983e75865c7c6a54b3e5f5b" => :mavericks
  end

  def install
    system "./configure", "--prefix=#{prefix}", "--disable-dependency-tracking"
    system "make", "install"
  end

  test do
    # assemble with gpasm
    (testpath/"test.asm").write " movlw 0x42\n end\n"
    system "#{bin}/gpasm", "-p", "p16f84", "test.asm"
    assert File.exist?("test.hex")

    # disassemble with gpdasm
    output = shell_output("#{bin}/gpdasm -p p16f84 test.hex")
    assert_match "0000:  3042  movlw   0x42\n", output
  end
end
