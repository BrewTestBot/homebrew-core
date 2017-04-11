class E2fsprogs < Formula
  desc "Utilities for the ext2, ext3, and ext4 file systems"
  homepage "https://e2fsprogs.sourceforge.io/"
  url "https://downloads.sourceforge.net/project/e2fsprogs/e2fsprogs/v1.43.4/e2fsprogs-1.43.4.tar.gz"
  mirror "https://www.kernel.org/pub/linux/kernel/people/tytso/e2fsprogs/v1.43.4/e2fsprogs-1.43.4.tar.gz"
  sha256 "1644db4fc58300c363ba1ab688cf9ca1e46157323aee1029f8255889be4bc856"

  head "https://git.kernel.org/pub/scm/fs/ext2/e2fsprogs.git"

  bottle do
    sha256 "6a62135604c22884a2bf7ac1d4fa0a04ae5f0ffb19e916977b3c4f370af43d7e" => :sierra
    sha256 "5c3c8238210a6046c8999092cc7f490e0d4a91e98ff6f90ca7d2c5923728389a" => :el_capitan
    sha256 "ccba1fffeaa3fad12b434ee7a7ab54a5fc191287c2bcb5b66905a435eda10d17" => :yosemite
    sha256 "3f95be44af372f34e747aa4b7a89a721a170cc0cafee21b5ae4b85c630d2972f" => :mavericks
  end

  keg_only "This brew installs several commands which override macOS-provided file system commands."

  depends_on "pkg-config" => :build
  depends_on "gettext"

  def install
    system "./configure", "--prefix=#{prefix}", "--disable-e2initrd-helper"
    system "make"
    system "make", "install"
    system "make", "install-libs"
  end

  test do
    assert_equal 36, shell_output("#{bin}/uuidgen").strip.length
    system bin/"lsattr", "-al"
  end
end
