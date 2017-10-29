class Subnetcalc < Formula
  desc "IPv4/IPv6 subnet calculator"
  homepage "https://www.uni-due.de/~be0001/subnetcalc/"
  url "https://www.uni-due.de/~be0001/subnetcalc/download/subnetcalc-2.4.8.tar.gz"
  sha256 "bb99c5e20e1f1861913d0747e32fcd9f174f674a723b5c255f44b7b43754ae09"

  bottle do
    cellar :any
    sha256 "16a221ea0e848f5f7ea80c0b4b2ec2d0cdf5ffaf7d3cf9de92823d99a4041908" => :high_sierra
    sha256 "79be89d64d55657a2ef79f136fe6900af7a83ac47cc66580efed81be88d56ae3" => :sierra
    sha256 "79d2a57a4226833e32b51d7989d6fa7886fdfdc0d05b63b77d95e56bc1fd3f19" => :el_capitan
    sha256 "13329556596cf2639947a221d340a4fee1cdd751f95c5fca578131464718a95f" => :yosemite
  end

  head do
    url "https://github.com/dreibh/subnetcalc.git"
    depends_on "automake" => :build
    depends_on "autoconf" => :build
    depends_on "libtool" => :build
  end

  depends_on "geoip" => :recommended

  def install
    args = ["--disable-dependency-tracking",
            "--disable-silent-rules",
            "--prefix=#{prefix}"]
    args << "--with-geoip=no" if build.without? "geoip"

    if build.head?
      system "./autogen.sh", *args
    else
      system "./configure", *args
    end
    system "make", "install"
  end

  test do
    system "#{bin}/subnetcalc", "::1"
  end
end
