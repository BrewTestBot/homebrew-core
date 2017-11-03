class MediaInfo < Formula
  desc "Unified display of technical and tag data for audio/video"
  homepage "https://mediaarea.net/"
  url "https://mediaarea.net/download/binary/mediainfo/17.10/MediaInfo_CLI_17.10_GNU_FromSource.tar.bz2"
  version "17.10"
  sha256 "2833fa4e72937d9c9f52a8ccf6a9e344ab3dfdf058c36fa6796cdce43f3029a2"

  bottle do
    cellar :any
    sha256 "32c2146bd17bb8538ef1b062790470031af5bc58a5febb7d3b0a4964a74673bf" => :high_sierra
    sha256 "c91bd7ac69bdcb3ea0bab8f82cf1922e246a73b459069899f902077478f29880" => :sierra
    sha256 "130e416b5b051151728a7a67a0af132056b9c047b152671ebde3015c3641b72c" => :el_capitan
  end

  depends_on "pkg-config" => :build

  def install
    cd "ZenLib/Project/GNU/Library" do
      args = ["--disable-debug",
              "--disable-dependency-tracking",
              "--enable-static",
              "--enable-shared",
              "--prefix=#{prefix}"]
      system "./configure", *args
      system "make", "install"
    end

    cd "MediaInfoLib/Project/GNU/Library" do
      args = ["--disable-debug",
              "--disable-dependency-tracking",
              "--with-libcurl",
              "--enable-static",
              "--enable-shared",
              "--prefix=#{prefix}"]
      system "./configure", *args
      system "make", "install"
    end

    cd "MediaInfo/Project/GNU/CLI" do
      system "./configure", "--disable-debug", "--disable-dependency-tracking",
                            "--prefix=#{prefix}"
      system "make", "install"
    end
  end

  test do
    pipe_output("#{bin}/mediainfo", test_fixtures("test.mp3"))
  end
end
