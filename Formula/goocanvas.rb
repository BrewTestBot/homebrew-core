class Goocanvas < Formula
  desc "Canvas widget for GTK+ using the Cairo 2D library for drawing"
  homepage "https://live.gnome.org/GooCanvas"
  url "https://download.gnome.org/sources/goocanvas/2.0/goocanvas-2.0.3.tar.xz"
  sha256 "6b5b9c25d32c05b9bafc42f5fcc28d55f1426e733e78e9fe4d191cfcd666c800"

  bottle do
    sha256 "d4bd80b46bc20db029d985ef65dc5e2792fd6d717333e74d2ac64bf9f4def920" => :sierra
    sha256 "a71314b56e99000a8dcce9df319c128abbe8d0b2dc88dc2d6c799aada5b106cf" => :el_capitan
    sha256 "d1c6ab2ec01306647c060409cac001856ecea0b83c3111eef3440f3055ae42f1" => :yosemite
  end

  depends_on "pkg-config" => :build
  depends_on "cairo"
  depends_on "glib"
  depends_on "gtk+3"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--enable-introspection=yes",
                          "--disable-gtk-doc-html"
    system "make", "install"
  end
end
