class Liboping < Formula
  desc "C library to generate ICMP echo requests"
  homepage "https://noping.cc/"
  url "https://noping.cc/files/liboping-1.10.0.tar.bz2"
  sha256 "eb38aa93f93e8ab282d97e2582fbaea88b3f889a08cbc9dbf20059c3779d5cd8"

  bottle do
    sha256 "d1f47bef9f08fa16e0dff46fc42ab617aa2a4124456a84db918c363cde62432d" => :sierra
    sha256 "2a5ed61ca95f5714209c1098a17eeac0f693d06d6882c3af9fabbbadf0e0d0c3" => :el_capitan
    sha256 "20a7a47dc6cdc3ffc058b04f36c0022d594f518cce1e389da1518f8649f5fdf1" => :yosemite
    sha256 "fa861b822a560e8dfde07a6e2fc1549100dbc9b02b9a5e13d0c8639479adc1c4" => :mavericks
    sha256 "ed0aaa7a4f7625d4ee4a7d50a9e9f2b96d8da45ecf184666988fb719dba1d735" => :mountain_lion
  end

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  def caveats
    "Run oping and noping sudo'ed in order to avoid the 'Operation not permitted'"
  end

  test do
    system bin/"oping", "-c", "1", "https://www.github.com"
  end
end
