class GnuTime < Formula
  desc "GNU implementation of time utility"
  homepage "https://www.gnu.org/software/time/"
  url "https://ftp.gnu.org/gnu/time/time-1.9.tar.gz"
  mirror "https://ftpmirror.gnu.org/time/time-1.9.tar.gz"
  sha256 "fbacf0c81e62429df3e33bda4cee38756604f18e01d977338e23306a3e3b521e"

  bottle do
    cellar :any_skip_relocation
    sha256 "0456f89fc3c1d696ddd7a1fb351fe10ebc934c9f3dea1a1e61dfde6b6d77b366" => :mojave
    sha256 "7be7fa7161f1c4256e7fd0427cc70bcb9942516cf087e3a4ce8bf25a8e9bda0e" => :high_sierra
    sha256 "4340f98cd4edd0512a7462ad52180a3dd4bd282fce7c53cadfe56c45f5367095" => :sierra
    sha256 "1f81b3521747ff00d913ac9f4c7e7d9ce8f19dd76a67c7d2b05d5dd228561883" => :el_capitan
  end

  option "with-default-names", "Do not prepend 'g' to the binary"

  def install
    args = [
      "--prefix=#{prefix}",
      "--mandir=#{man}",
      "--info=#{info}",
    ]

    args << "--program-prefix=g" if build.without? "default-names"

    system "./configure", *args
    system "make", "install"

    if build.without? "default-names"
      (libexec/"gnubin").install_symlink bin/"gtime" => "time"
    end
  end

  test do
    system bin/"gtime", "ruby", "--version"
  end
end
