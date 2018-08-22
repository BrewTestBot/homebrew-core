class Libmrss < Formula
  desc "C library for RSS files or streams"
  homepage "https://www.autistici.org/bakunin/libmrss/"
  url "https://www.autistici.org/bakunin/libmrss/libmrss-0.19.2.tar.gz"
  sha256 "071416adcae5c1a9317a4a313f2deb34667e3cc2be4487fb3076528ce45b210b"

  bottle do
    cellar :any
    rebuild 1
    sha256 "ee283af3f89ae1e38408a4fe77df32218845aef0dc096aefc49149bcb42e611b" => :mojave
    sha256 "0aa71e057813f04d6ec6682f81c1b0dfdde634cb37f3adadb1083a5337fd1ad8" => :high_sierra
    sha256 "18314ef43a046f7944ef92cc3d08fdff60168a170fadb89aeeaa33ed927c9d01" => :sierra
    sha256 "85da9deb7189d65de0cd834a3b6777358a2cc263b4626de3b4036cc99a82fa8c" => :el_capitan
    sha256 "6ffc4597ea7c697b8d6c0e39196fc748e99bc5b29ec40651c17a7cce97de1cce" => :yosemite
    sha256 "ab5aef7bbf64a913dedec5d77b8e0345ea1ad83eace9a98cffa045d461cdd277" => :mavericks
    sha256 "c0cd9c230ce54c44826b6b8915eb61791b789518c921903af54b50e59d51d92e" => :mountain_lion
  end

  depends_on "pkg-config" => :build
  depends_on "libnxml"

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end
