class Epic5 < Formula
  desc "Enhanced, programmable IRC client"
  homepage "http://www.epicsol.org/"
  url "http://ftp.epicsol.org/pub/epic/EPIC5-PRODUCTION/epic5-2.0.1.tar.xz"
  sha256 "55260fc832c76f7a4975bde2bd0d0805fd8012fc8908ac94ec8c6de24a1be7aa"
  head "http://git.epicsol.org/epic5.git"

  bottle do
    sha256 "3ea96f2a4be750e64b9d5219764aef858a5b58f997ceb7bcf5b1d85bf088542c" => :el_capitan
    sha256 "a868d664e78c1b424d514db8f5d421d59bf02e3a7e79738850ce1e67139ebd8c" => :yosemite
    sha256 "3e71127bb305c3f5fe6d226b67e4e7d9b2c02220afc042315b1d3e2fa5b2756f" => :mavericks
  end

  depends_on "openssl"

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--mandir=#{man}",
                          "--with-ipv6",
                          "--with-ssl=#{Formula["openssl"].opt_prefix}"
    system "make"
    system "make", "test"
    system "make", "install"
  end

  test do
    connection = fork do
      exec bin/"epic5", "irc.freenode.net"
    end
    sleep 5
    Process.kill("TERM", connection)
  end
end
