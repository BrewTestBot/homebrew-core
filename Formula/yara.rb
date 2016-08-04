class Yara < Formula
  desc "Malware identification and classification tool"
  homepage "https://github.com/VirusTotal/yara/"
  url "https://github.com/VirusTotal/yara/archive/v3.5.0.tar.gz"
  sha256 "ff2ee440515684c272df52febc8b73e730ca99ce194c24bd3cb43bec2b4c47f2"
  head "https://github.com/VirusTotal/yara.git"

  bottle do
    cellar :any
    revision 1
    sha256 "3794f28f0cec51b052105d03fa163724778d797ce00ca4ab912db8d9f0e6f0d0" => :el_capitan
    sha256 "6f12300a6296b73c9a3630c46e7f7a95b7b180fb13754ce1b9e32d14b1bd8c6c" => :yosemite
    sha256 "e7709cb0b1c47bbab784790c1ffb1929ec63dc05ee1c8864ba7b53ac60aad759" => :mavericks
  end

  depends_on "libtool" => :build
  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on :python if MacOS.version <= :snow_leopard
  depends_on "openssl"

  def install
    system "./bootstrap.sh"
    system "./configure", "--disable-silent-rules",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    rules = testpath/"commodore.yara"
    rules.write <<-EOS.undent
      rule chrout {
        meta:
          description = "Calls CBM KERNAL routine CHROUT"
        strings:
          $jsr_chrout = {20 D2 FF}
          $jmp_chrout = {4C D2 FF}
        condition:
          $jsr_chrout or $jmp_chrout
      }
    EOS

    program = testpath/"zero.prg"
    program.binwrite [0x00, 0xc0, 0xa9, 0x30, 0x4c, 0xd2, 0xff].pack("C*")

    assert_equal "chrout #{program}", shell_output("#{bin}/yara #{rules} #{program}").strip
  end
end
