class Elinks < Formula
  desc "Text mode web browser"
  homepage "http://elinks.or.cz/"
  url "http://elinks.or.cz/download/elinks-0.11.7.tar.bz2"
  sha256 "456db6f704c591b1298b0cd80105f459ff8a1fc07a0ec1156a36c4da6f898979"
  revision 3

  bottle do
    rebuild 3
    sha256 "16c9911afafae0c541fc2e004db9dd6666c8f4401aaeb26c25875d8de2082f99" => :mojave
    sha256 "d467cc8c41448e3e2a88b4796eb318bc9dabb30c46ec9b73db023ca83fcbee9b" => :high_sierra
    sha256 "4b9ce9f2668471292e159b1e2c2590f71b783c1d6debfa73c92dadbc96b57fba" => :sierra
  end

  head do
    url "http://elinks.cz/elinks.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "openssl@1.1"

  # Two patches for compatibility with OpenSSL 1.1, from FreeBSD:
  # https://www.freshports.org/www/elinks/
  patch :p0 do
    url "https://reviews.freebsd.org/file/data/mhvwibmet2v2udg4zxej/PHID-FILE-t5ovwhj2ffidzafayfj7/patch-src_network_ssl_socket.c"
    sha256 "a4f199f6ce48989743d585b80a47bc6e0ff7a4fa8113d120e2732a3ffa4f58cc"
  end

  patch :p0 do
    url "https://reviews.freebsd.org/file/data/gnlzo63jiq6hqudtanmv/PHID-FILE-3mj6cioca2hw4bpk76i5/patch-src_network_ssl_ssl.c"
    sha256 "45c140d5db26fc0d98f4d715f5f355e56c12f8009a8dd9bf20b05812a886c348"
  end

  def install
    ENV.deparallelize
    ENV.delete("LD")
    system "./autogen.sh" if build.head?
    system "./configure", "--prefix=#{prefix}",
                          "--without-spidermonkey",
                          "--enable-256-colors"
    system "make", "install"
  end

  test do
    (testpath/"test.html").write <<~EOS
      <!DOCTYPE html>
      <title>elinks test</title>
      Hello world!
      <ol><li>one</li><li>two</li></ol>
    EOS
    assert_match /^\s*Hello world!\n+ *1. one\n *2. two\s*$/,
                 shell_output("#{bin}/elinks test.html")
  end
end
