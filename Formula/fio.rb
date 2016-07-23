class Fio < Formula
  desc "I/O benchmark and stress test"
  homepage "http://freecode.com/projects/fio"
  url "https://github.com/axboe/fio/archive/fio-2.13.tar.gz"
  sha256 "7b1d0fb68d8468acbac2b6f814e323b74085a7207f45524f7c1fc472e79bc91d"
  head "git://git.kernel.dk/fio.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "c8329406654f4e36660d6679a171bec8060f22ece7fe44d0b46c85acbc6c4b2d" => :el_capitan
    sha256 "a021f77ccd607011fdb850020a10a53541ecdb9fede1ab120387be75973cad26" => :yosemite
    sha256 "4bb96f6205c8289f75c25e43d6c7bf3bd400b4c002c3de11889dcc51d5d8f50a" => :mavericks
  end

  def install
    system "./configure"
    # fio's CFLAGS passes vital stuff around, and crushing it will break the build
    system "make", "prefix=#{prefix}",
                   "mandir=#{man}",
                   "sharedir=#{share}",
                   "CC=#{ENV.cc}",
                   "V=true", # get normal verbose output from fio's makefile
                   "install"
  end

  test do
    system "#{bin}/fio", "--parse-only"
  end
end
