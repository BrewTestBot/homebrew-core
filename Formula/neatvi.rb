class Neatvi < Formula
  desc "ex/vi clone for editing bidirectional utf-8 text"
  homepage "https://repo.or.cz/neatvi.git"
  url "https://repo.or.cz/neatvi.git",
      :tag      => "07",
      :revision => "cfb5f5f6170fa3c66566a81ce2a4d17c60c563aa"
  head "https://repo.or.cz/neatvi.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "8026ebd4c6514ec20926b1ae3a2e5085d61aa193141f29a2744132b8bbe56ad1" => :catalina
    sha256 "c9dfd1c69ab95ee511c1b27768166e5cba516b6c283e5b168db2451d3865fc44" => :mojave
    sha256 "2e34d03e212479074e86e8d1024447badeb61a54205f1fda24f9b6633e22afe7" => :high_sierra
    sha256 "339a7880dea5f7ff0e290bc890f95719da7e5ba4b64a7205760c8f6cf64e10a2" => :sierra
    sha256 "c773025ad559bb25cc095a7e1efc8950424a4cd86ff81ee4b0093a0e2e3c3c84" => :el_capitan
  end

  def install
    system "make"
    bin.install "vi" => "neatvi"
  end

  test do
    pipe_output("#{bin}/neatvi", ":q\n")
  end
end
