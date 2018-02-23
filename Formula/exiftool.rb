class Exiftool < Formula
  desc "Perl lib for reading and writing EXIF metadata"
  homepage "https://www.sno.phy.queensu.ca/~phil/exiftool/index.html"
  # Ensure release is tagged production before submitting.
  # https://www.sno.phy.queensu.ca/~phil/exiftool/history.html
  url "https://www.sno.phy.queensu.ca/~phil/exiftool/Image-ExifTool-10.80.tar.gz"
  mirror "https://downloads.sourceforge.net/project/exiftool/Image-ExifTool-10.80.tar.gz"
  sha256 "bcf896600776d8ef39a867081b48426837ed5ee8ca19b53dd9d86a3179c93c93"

  bottle do
    cellar :any_skip_relocation
    sha256 "5039ab4f2bc31d2afc9b4cd1fab9ab5d6deec2bf2d1bba0a95f4d54e747dd117" => :high_sierra
    sha256 "5039ab4f2bc31d2afc9b4cd1fab9ab5d6deec2bf2d1bba0a95f4d54e747dd117" => :sierra
    sha256 "5039ab4f2bc31d2afc9b4cd1fab9ab5d6deec2bf2d1bba0a95f4d54e747dd117" => :el_capitan
  end

  def install
    # replace the hard-coded path to the lib directory
    inreplace "exiftool", "$exeDir/lib", libexec/"lib"

    system "perl", "Makefile.PL"
    system "make", "all"
    libexec.install "lib"
    bin.install "exiftool"
    doc.install Dir["html/*"]
    man1.install "blib/man1/exiftool.1"
    man3.install Dir["blib/man3/*"]
  end

  test do
    test_image = test_fixtures("test.jpg")
    assert_match %r{MIME Type\s+: image/jpeg},
                 shell_output("#{bin}/exiftool #{test_image}")
  end
end
