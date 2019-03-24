class GnuSmalltalk < Formula
  desc "GNU Smalltalk interpreter and image"
  homepage "http://smalltalk.gnu.org/"
  url "https://ftp.gnu.org/gnu/smalltalk/smalltalk-3.2.5.tar.xz"
  mirror "https://ftpmirror.gnu.org/smalltalk/smalltalk-3.2.5.tar.xz"
  sha256 "819a15f7ba8a1b55f5f60b9c9a58badd6f6153b3f987b70e7b167e7755d65acc"
  revision 8
  head "https://github.com/gnu-smalltalk/smalltalk.git"

  bottle do
    rebuild 1
    sha256 "fe64de43c6e4db524e5068a82b70b3669dd4dab3ab2800ee1babf0b927dea1e9" => :mojave
  end

  devel do
    url "https://alpha.gnu.org/gnu/smalltalk/smalltalk-3.2.91.tar.gz"
    sha256 "13a7480553c182dbb8092bd4f215781b9ec871758d1db7045c2d8587e4d1bef9"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "gawk" => :build
  depends_on "pkg-config" => :build
  depends_on "gdbm"
  depends_on "gnutls"
  depends_on "libffi"
  depends_on "libsigsegv"
  depends_on "libtool"
  depends_on "readline"

  def install
    # Fix build failure "Symbol not found: _clock_gettime"
    if MacOS.version == "10.11" && MacOS::Xcode.version >= "8.0"
      ENV["ac_cv_search_clock_gettime"] = "no"
    end

    args = %W[
      --disable-debug
      --disable-dependency-tracking
      --prefix=#{prefix}
      --with-lispdir=#{elisp}
      --disable-gtk
      --with-readline=#{Formula["readline"].opt_lib}
      --without-tcl
      --without-tk
      --without-x
    ]

    system "autoreconf", "-ivf"
    system "./configure", *args
    system "make"
    system "make", "install"
  end

  test do
    path = testpath/"test.gst"
    path.write "0 to: 9 do: [ :n | n display ]\n"

    assert_match "0123456789", shell_output("#{bin}/gst #{path}")
  end
end
