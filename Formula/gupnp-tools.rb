class GupnpTools < Formula
  desc "Free replacements of Intel's UPnP tools."
  homepage "https://wiki.gnome.org/GUPnP/"
  url "https://download.gnome.org/sources/gupnp-tools/0.8/gupnp-tools-0.8.14.tar.xz"
  sha256 "682b952b3cf43818c7d27549c152ea52e43320500820ab3392cf5a29a95e7efa"

  bottle do
    sha256 "1dbf58cfb3c0a52e8032312e6090e88c4c0ddb2bb93de11dd9e0bb4feb9a8a55" => :sierra
    sha256 "8920d8009d36e84e71e4d55ded1c5f8d3141bb4d9729b476c1dd49375c065dcd" => :el_capitan
    sha256 "ab31a427466e442cb51e337572428cbc3c36a390e2043a6c150f1decb16eb59b" => :yosemite
  end

  depends_on "pkg-config" => :build
  depends_on "intltool" => :build
  depends_on "gettext"
  depends_on "gupnp"
  depends_on "gupnp-av"
  depends_on "gtk+3"
  depends_on "gtksourceview3"

  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "#{bin}/gupnp-universal-cp", "-h"
    system "#{bin}/gupnp-av-cp", "-h"
  end
end
