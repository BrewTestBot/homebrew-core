class Opensc < Formula
  desc "Tools and libraries for smart cards"
  homepage "https://github.com/OpenSC/OpenSC/wiki"
  url "https://github.com/OpenSC/OpenSC/releases/download/0.18.0/opensc-0.18.0.tar.gz"
  sha256 "9bc0ff030dd1c10f646d54415eae1bb2b1c72dda710378343f027e17cd8c3757"
  head "https://github.com/OpenSC/OpenSC.git"

  bottle do
    sha256 "6784d3e0123aa57babbec1f6d88d01d37ef749b35aad0ab8c0b2944d255eb460" => :mojave
    sha256 "84b81199751659ed73c4209849aa1f0ed5534788fcdab9c2748f1e765613820f" => :high_sierra
    sha256 "107d1798ed7303d793aeeae634e44a05cff93a7e65ae6a3635a4567e117d47df" => :sierra
    sha256 "8be12043d847a94cd56524734f99e49f5bfa884d84ea3c70fa9347d30b8a7ea1" => :el_capitan
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "docbook-xsl" => :build
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build
  depends_on "openssl"

  def install
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --enable-openssl
      --enable-pcsc
      --enable-sm
      --with-xsl-stylesheetsdir=#{Formula["docbook-xsl"].opt_prefix}/docbook-xsl
    ]

    system "./bootstrap"
    system "./configure", *args
    system "make", "install"
  end
end
