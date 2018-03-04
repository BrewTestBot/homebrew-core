class Feh < Formula
  desc "X11 image viewer"
  homepage "https://feh.finalrewind.org/"
  url "https://feh.finalrewind.org/feh-2.25.tar.bz2"
  sha256 "063bec0138103cf5c52594c6ffe8946d6c48cf5a664f03634634010b46e45980"

  bottle do
    sha256 "1d41b44b5bbe5b01d182b2b2038151e607fb1d52fae855c05b54ab272b580973" => :high_sierra
    sha256 "c33b68556fc84dd37b805a804f8a05511afcad774b7d7bc342d645eecca6696d" => :sierra
    sha256 "aef92ce6ef6d93a59ac2e6511baa5e4cf9fc62df94c39a7c7b2e4498a7a55652" => :el_capitan
  end

  depends_on :x11
  depends_on "imlib2"
  depends_on "libexif" => :recommended

  def install
    args = ["verscmp=0"]
    args << "exif=1" if build.with? "libexif"
    system "make", "PREFIX=#{prefix}", *args
    system "make", "PREFIX=#{prefix}", "install"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/feh -v")
  end
end
