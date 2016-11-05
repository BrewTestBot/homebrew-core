class Ipbt < Formula
  desc "Program for recording a UNIX terminal session"
  homepage "http://www.chiark.greenend.org.uk/~sgtatham/ipbt/"
  url "http://www.chiark.greenend.org.uk/~sgtatham/ipbt/ipbt-20160908.4a07ab0.tar.gz"
  version "20160908"
  sha256 "7414ba38041c283db3b2c7bc119eecfcb193629c50f8509bd4693142813cea5d"

  bottle do
    cellar :any_skip_relocation
    sha256 "2a0909001f6dd70a27e1f2a595c86043f03f1c7064a3a7bbffc339a4c2a4f327" => :el_capitan
    sha256 "31cb431e2612d8eb4c1fc1653d675c2d6789c74acf3fbe09367df8e0b5350a8e" => :yosemite
    sha256 "d5ae41af0fa56f3cfb1e5fef2e17fb20fc2d18b2b1c11ecb0f0d57fd97edfc58" => :mavericks
    sha256 "2f6782c8fa4d72545b367c6a210d58bffa87db3e36c8d66ac28934183a6d4547" => :mountain_lion
  end

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--disable-dependency-tracking"
    system "make", "install"
  end

  test do
    system "#{bin}/ipbt"
  end
end
