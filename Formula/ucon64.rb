class Ucon64 < Formula
  desc "ROM backup tool and emulator's Swiss Army knife program"
  homepage "https://ucon64.sourceforge.io/"
  url "https://downloads.sourceforge.net/ucon64/ucon64-2.0.2-src.tar.gz"
  sha256 "2df3972a68d1d7237dfedb99803048a370b466a015a5e4c1343f7e108601d4c9"
  head "https://svn.code.sf.net/p/ucon64/svn/trunk/ucon64"

  bottle do
    rebuild 1
    sha256 "4ac0272a1cd22710a37fcff9b632e06385876b97cb8faf261b22b0a9523457ed" => :high_sierra
    sha256 "af7e5a61ca8f612fcf181d8d3df1585791ef1962261ca70f4d31973d6493e607" => :sierra
    sha256 "103292bd5e30f9487e28612404b0176a889f010ea76ed93e14cb2ea32358ab53" => :el_capitan
  end

  resource "super_bat_puncher_demo" do
    url "http://morphcat.de/superbatpuncher/Super%20Bat%20Puncher%20Demo.zip"
    sha256 "d74cb3ba11a4ef5d0f8d224325958ca1203b0d8bb4a7a79867e412d987f0b846"
  end

  def install
    # ucon64's normal install process installs the discmage library in
    # the user's home folder. We want to store it inside the prefix, so
    # we have to change the default value of ~/.ucon64rc to point to it.
    # .ucon64rc is generated by the binary, so we adjust the default that
    # is set when no .ucon64rc exists.
    inreplace "src/ucon64_misc.c", 'PROPERTY_MODE_DIR ("ucon64") "discmage.dylib"',
                                   "\"#{opt_prefix}/libexec/libdiscmage.dylib\""

    cd "src" do
      system "./configure", "--disable-debug",
                            "--disable-dependency-tracking",
                            "--disable-silent-rules",
                            "--prefix=#{prefix}"
      system "make"
      bin.install "ucon64"
      libexec.install "libdiscmage/discmage.so" => "libdiscmage.dylib"
    end
  end

  def caveats
    <<~EOS
      You can copy/move your DAT file collection to $HOME/.ucon64/dat
      Be sure to check $HOME/.ucon64rc for configuration after running uCON64
      for the first time.
    EOS
  end

  test do
    resource("super_bat_puncher_demo").stage testpath

    assert_match "00000000  4e 45 53 1a  08 00 11 00  00 00 00 00  00 00 00 00",
                 shell_output("#{bin}/ucon64 \"#{testpath}/Super Bat Puncher Demo.nes\"")
  end
end
