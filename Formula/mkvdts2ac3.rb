class Mkvdts2ac3 < Formula
  desc "Convert DTS audio to AC3 within a matroska file"
  homepage "https://github.com/JakeWharton/mkvdts2ac3"
  revision 3
  head "https://github.com/JakeWharton/mkvdts2ac3.git"

  stable do
    url "https://github.com/JakeWharton/mkvdts2ac3/archive/1.6.0.tar.gz"
    sha256 "f9f070c00648c1ea062ac772b160c61d1b222ad2b7d30574145bf230e9288982"

    # patch with upstream fix for newer mkvtoolnix compatibility
    # https://github.com/JakeWharton/mkvdts2ac3/commit/f5008860e7ec2cbd950a0628c979f06387bf76d0
    patch do
      url "https://raw.githubusercontent.com/Homebrew/formula-patches/85fa66a9/mkvdts2ac3/1.6.0.patch"
      sha256 "208393d170387092cb953b6cd32e8c0201ba73560e25ed4930e4e2af6f72e4d9"
    end
  end

  bottle do
    cellar :any_skip_relocation
    rebuild 1
    sha256 "8fd943a22eea3a32d29f62bad325347dc33c0489d5d333070f25087bea39227b" => :catalina
    sha256 "8fd943a22eea3a32d29f62bad325347dc33c0489d5d333070f25087bea39227b" => :mojave
    sha256 "8fd943a22eea3a32d29f62bad325347dc33c0489d5d333070f25087bea39227b" => :high_sierra
  end

  depends_on "ffmpeg"
  depends_on "mkvtoolnix"

  def install
    bin.install "mkvdts2ac3.sh" => "mkvdts2ac3"
  end

  test do
    system "#{bin}/mkvdts2ac3", "--version"
  end
end
