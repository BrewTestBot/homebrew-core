class SimpleScan < Formula
  desc "GNOME document scanning application"
  homepage "https://gitlab.gnome.org/GNOME/simple-scan"
  url "https://download.gnome.org/sources/simple-scan/3.34/simple-scan-3.34.1.tar.xz"
  sha256 "d827fec3383a565724136b6fda543a94c8f8f161782ac6edf9e91ed6fad49f3e"

  bottle do
    sha256 "f7ed7cc755f1ea1584992c7f80f2c1b9c7df40fea51d0f69e09f007508e4be3a" => :catalina
    sha256 "3ac910e141f6abec6cebf8f87f52529bb28c6720b407a6b0b011cc5365ec0d37" => :mojave
    sha256 "eb7cdfbc69616ce9da492826f32b50bb8907fb0e6beb25bd9c484940faff5e15" => :high_sierra
  end

  depends_on "itstool" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "python" => :build
  depends_on "vala" => :build
  depends_on "glib"
  depends_on "gtk+3"
  depends_on "libgusb"
  depends_on "sane-backends"
  depends_on "webp"

  def install
    ENV["DESTDIR"] = "/"
    mkdir "build" do
      system "meson", "--prefix=#{prefix}", ".."
      system "ninja", "-v"
      system "ninja", "install", "-v"
    end
  end

  def post_install
    system "#{Formula["glib"].opt_bin}/glib-compile-schemas", "#{HOMEBREW_PREFIX}/share/glib-2.0/schemas"
    system "#{Formula["gtk+3"].opt_bin}/gtk3-update-icon-cache", "-f", "-t", "#{HOMEBREW_PREFIX}/share/icons/hicolor"
  end

  test do
    system "#{bin}/simple-scan", "-v"
  end
end
