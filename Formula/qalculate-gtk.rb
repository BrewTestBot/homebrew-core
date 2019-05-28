class QalculateGtk < Formula
  desc "Multi-purpose desktop calculator"
  homepage "https://qalculate.github.io/"
  url "https://github.com/Qalculate/qalculate-gtk/releases/download/v3.2.0/qalculate-gtk-3.2.0.tar.gz"
  sha256 "b9374d6c253418c8666db29102ff7525b9785a123318702a55c422b70c1b36b5"

  bottle do
    cellar :any
    sha256 "4c79a0e97faf61b8fc6332ea94ee1037b87bde8900a4ccfec68b293078aef9a7" => :mojave
    sha256 "38ac8f760ad4d1222543f4fe1bfda0c31d5d3f888480d7a8bb19aa6d3a95933f" => :high_sierra
    sha256 "b540fd9c3f36b49252677e42459b3b7a1602c843b0de0db738bc656c437a31f5" => :sierra
  end

  depends_on "intltool" => :build
  depends_on "pkg-config" => :build
  depends_on "adwaita-icon-theme"
  depends_on "gtk+3"
  depends_on "libqalculate"

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "#{bin}/qalculate-gtk", "-v"
  end
end
