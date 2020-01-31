class Libpst < Formula
  desc "Utilities for the PST file format"
  homepage "https://www.five-ten-sg.com/libpst/"
  url "https://www.five-ten-sg.com/libpst/packages/libpst-0.6.74.tar.gz"
  sha256 "f787dadce74a9578939ab54babb3f3f0086808cdee2370d7faac9e1fad44fd37"

  bottle do
    cellar :any
    sha256 "deebf5c542e32c4db5a6409743c2e20d55b3151e96a999962990c6d8c9c7ce39" => :catalina
    sha256 "713575b82c8c6121fb24b6e81f3db9c97269ce36b7437bf627005aca52adbd0c" => :mojave
    sha256 "53d20866aae36d6c27f70b87ca5ebdc95fce3812c0f7867ace75195851cb9255" => :high_sierra
    sha256 "ba6f9f3cc335802c9dd31f7098c71c06adcc014ac4de0f821cd823956a6839fc" => :sierra
  end

  depends_on "pkg-config" => :build
  depends_on "boost"
  depends_on "gettext"
  depends_on "libgsf"

  def install
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --disable-python
    ]

    system "./configure", *args
    system "make"
    system "make", "install"
  end

  test do
    system bin/"lspst", "-V"
  end
end
