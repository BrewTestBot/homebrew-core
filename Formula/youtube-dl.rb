# Please only update to versions that are published on PyPi as there are too
# many releases for us to update to every single one:
# https://pypi.python.org/pypi/youtube_dl
class YoutubeDl < Formula
  desc "Download YouTube videos from the command-line"
  homepage "https://rg3.github.io/youtube-dl/"
  url "https://yt-dl.org/downloads/2016.04.06/youtube-dl-2016.04.06.tar.gz"
  sha256 "115a7443162198f12d97c2c1d83e69d462f78410a26d6dd5ae3c74603397b9cd"

  bottle do
    cellar :any_skip_relocation
    revision 1
    sha256 "52c47e21d6a4014999012c4dab29d7743a4ce0e8d89f3d513d3a902a7ce14c77" => :el_capitan
    sha256 "8c69c3ede6e7739fb75ed8767ea8ad98c02e644249421814efcdae709e6c5a55" => :yosemite
    sha256 "2867dc568b3c17213921a3bbe6b601f9ed051f4c7fc54937976b0549bf8602ff" => :mavericks
  end

  head do
    url "https://github.com/rg3/youtube-dl.git"
    depends_on "pandoc" => :build
  end

  option "with-ffmpeg", "Install ffmpeg as well to use post-processing options"
  option "with-libav", "Install libav as well to use post-processing options"

  depends_on "ffmpeg" => :optional
  depends_on "libav" => :optional
  depends_on "rtmpdump" => :optional

  def install
    system "make", "PREFIX=#{prefix}"
    bin.install "youtube-dl"
    man1.install "youtube-dl.1"
    bash_completion.install "youtube-dl.bash-completion"
    zsh_completion.install "youtube-dl.zsh" => "_youtube-dl"
    fish_completion.install "youtube-dl.fish"
  end

  test do
    system "#{bin}/youtube-dl", "--simulate", "https://www.youtube.com/watch?v=he2a4xK8ctk"
    system "#{bin}/youtube-dl", "--simulate", "--yes-playlist", "https://www.youtube.com/watch?v=AEhULv4ruL4&list=PLZdCLR02grLrl5ie970A24kvti21hGiOf"
  end
end
