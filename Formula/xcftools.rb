class Xcftools < Formula
  desc "Tools for GIMP's native file format XCF"
  homepage "http://henning.makholm.net/software"
  url "http://henning.makholm.net/xcftools/xcftools-1.0.7.tar.gz"
  sha256 "1ebf6d8405348600bc551712d9e4f7c33cc83e416804709f68d0700afde920a6"

  depends_on "libpng"

  def install
    # Apply patch to build with libpng-1.5 or above
    # http://anonscm.debian.org/cgit/collab-maint/xcftools.git/commit/?id=c40088b82c6a788792aae4068ddc8458de313a9b
    inreplace "xcf2png.c", /png_(voidp|error_ptr)_NULL/, "NULL"

    # Avoid GNU-only `install -D` and create directories manually
    inreplace "Makefile.in", /(@INSTALL@) -D/, '\1'
    bin.mkpath
    man1.mkpath

    system "./configure", "--prefix=#{prefix}"

    # Avoid `touch` error from empty MANLINGUAS when building without NLS
    touch "manpo/manpages.pot"
    system "make", "manpo/manpages.pot"

    system "make", "install"
  end

  test do
    # 1x1 blue pixel generated by GIMP 2.8.16
    xcf = %w[
      67696d70207863662066696c65000000000100000001000000000000001100000001010000
      00130000000842900000429000000000001400000004000000030000001600000004000000
      01000000150000011c0000001067696d702d696d6167652d67726964000000000100000100
      287374796c6520736f6c6964290a286667636f6c6f722028636f6c6f722d7267626120302e
      30303030303020302e30303030303020302e30303030303020312e30303030303029290a28
      6267636f6c6f722028636f6c6f722d7267626120312e30303030303020312e303030303030
      20312e30303030303020312e30303030303029290a287873706163696e672031302e303030
      303030290a287973706163696e672031302e303030303030290a2873706163696e672d756e
      697420696e63686573290a28786f666673657420302e303030303030290a28796f66667365
      7420302e303030303030290a286f66667365742d756e697420696e63686573290a00000000
      00000000000000018300000000000000000000000100000001000000000000000b4261636b
      67726f756e640000000002000000000000000600000004000000ff00000008000000040000
      00010000000900000004000000000000001c00000004000000000000000a00000004000000
      000000000b00000004000000000000000c00000004000000000000000d0000000400000000
      0000000f000000080000000000000000000000070000000400000000000000140000000400
      00000200000000000000000000023e00000000000000010000000100000003000002520000
      0000000000010000000100000262000000000000000000ff
    ].join
    (testpath/"test.xcf").binwrite [xcf].pack("H*")

    info = <<-EOS.undent
      Version 0, 1x1 RGB color, 1 layers, compressed RLE
      + 1x1+0+0 RGB Normal Background
    EOS
    assert_equal info, shell_output("#{bin}/xcfinfo test.xcf")

    pnm = "P6 # Converted by xcf2pnm #{version}\n1 1\n255\n\x00\x00\xFF"
    assert_equal pnm, shell_output("#{bin}/xcf2pnm test.xcf")
  end
end
