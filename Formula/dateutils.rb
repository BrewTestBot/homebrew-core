class Dateutils < Formula
  desc "Tools to manipulate dates with a focus on financial data"
  homepage "https://www.fresse.org/dateutils/"
  url "https://github.com/hroptatyr/dateutils/releases/download/v0.4.4/dateutils-0.4.4.tar.xz"
  sha256 "a9cc2efbb10681130ac725946984e12330e94f43877d865d7f5c131dcf09c84f"

  bottle do
    sha256 "21e481eb6f462bc525ac1b37dd816ea63f8d56fba328f34540c10a8a2d367dfd" => :high_sierra
    sha256 "e0f523c86070087139383d3ab86ae25abcae2904148478b71e343bec101eb62b" => :sierra
    sha256 "89d36dc29ffa59f15ce4a8d16d6dc981590efe8e4989633d9748e95baade4a98" => :el_capitan
  end

  head do
    url "https://github.com/hroptatyr/dateutils.git"
    depends_on "automake" => :build
    depends_on "autoconf" => :build
    depends_on "libtool" => :build
  end

  def install
    system "autoreconf", "-iv" if build.head?
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    output = shell_output("#{bin}/dconv 2012-03-04 -f \"%Y-%m-%c-%w\"").strip
    assert_equal "2012-03-01-00", output
  end
end
