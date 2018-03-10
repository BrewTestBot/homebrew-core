class Par2 < Formula
  desc "Parchive: Parity Archive Volume Set for data recovery"
  homepage "https://github.com/Parchive/par2cmdline"
  url "https://github.com/Parchive/par2cmdline/releases/download/v0.8.0/par2cmdline-0.8.0.tar.bz2"
  sha256 "496430e185f2d82e54245a0554341a1826f06c5e673fa12a10f176c7f9b42964"

  bottle do
    cellar :any_skip_relocation
    rebuild 1
    sha256 "78a6b4ef2ef1d3785e51280c493f1206a9b2c1b55b7adba2403612aa0d17dbde" => :high_sierra
    sha256 "2924b769db754907e12025d332a1cb227b4953c3350982782e561f3691caae92" => :sierra
    sha256 "36b3991860c78ffc40be60a45bba36614b233d0274540a410b4240c557f62cec" => :el_capitan
  end

  option "with-openmp", "Build with OpenMP multithreading support"

  if build.with? "openmp"
    depends_on "gcc"
    fails_with :clang
  end

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    # Protect a file with par2.
    test_file = testpath/"some-file"
    File.write(test_file, "file contents")
    system "#{bin}/par2", "create", test_file

    # "Corrupt" the file by overwriting, then ask par2 to repair it.
    File.write(test_file, "corrupted contents")
    repair_command_output = shell_output("#{bin}/par2 repair #{test_file}")

    # Verify that par2 claimed to repair the file.
    assert_match "1 file(s) exist but are damaged.", repair_command_output
    assert_match "Repair complete.", repair_command_output

    # Verify that par2 actually repaired the file.
    assert File.read(test_file) == "file contents"
  end
end
