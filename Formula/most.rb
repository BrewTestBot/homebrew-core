class Most < Formula
  desc "Powerful paging program"
  homepage "https://www.jedsoft.org/most/"
  url "https://www.jedsoft.org/releases/most/most-5.1.0.tar.gz"
  sha256 "db805d1ffad3e85890802061ac8c90e3c89e25afb184a794e03715a3ed190501"
  head "git://git.jedsoft.org/git/most.git"

  bottle do
    sha256 "af9a922f4a08dbd0afd272fbe8eef56bd2437691721cdff0571531255a61b0ca" => :mojave
    sha256 "90678b6798fb5eaadf38359fc8f1652fb8dbe3c96c58113742a0727a3d3fb51c" => :high_sierra
    sha256 "33ff883a9327d71e8d8eaffeb7e12e224ac1e04f06bd3d940317e7d9c431145b" => :sierra
    sha256 "9e645b60950d18dea0b58c95b0525992cb55bbddc5cdc664dce11e94b552e568" => :el_capitan
    sha256 "7b2828c656ba7ef31fc03d5570f8d6701f365fd4a96252bcdfae66b266713bc3" => :yosemite
    sha256 "f7d99563678653a673eddee924ca90f76819eed8a25a47780762571f35187241" => :mavericks
  end

  depends_on "s-lang"

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--with-slang=#{HOMEBREW_PREFIX}"
    system "make", "install"
  end

  test do
    text = "This is Homebrew"
    assert_equal text, pipe_output("#{bin}/most -C", text)
  end
end
