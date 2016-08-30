class Konoha < Formula
  desc "Static scripting language with extensible syntax"
  homepage "https://github.com/konoha-project/konoha3"
  url "https://github.com/konoha-project/konoha3/archive/v0.1.tar.gz"
  sha256 "e7d222808029515fe229b0ce1c4e84d0a35b59fce8603124a8df1aeba06114d3"
  revision 1

  bottle do
    rebuild 1
    sha256 "cd510909891fc0b943425cf2e9f2a992da63278f4481d79a72d3b924131dd39e" => :el_capitan
    sha256 "107bd8a085b85ed5e0d761af86117c3859e62df2d4de57ca14cc32432731b674" => :mavericks
  end

  head do
    url "https://github.com/konoha-project/konoha3.git"

    depends_on "openssl"
  end

  option "with-test", "Verify the build with make test (May currently fail)"

  deprecated_option "tests" => "with-test"

  depends_on "cmake" => :build
  depends_on :mpi => [:cc, :cxx, :optional]
  depends_on "pcre"
  depends_on "json-c"
  depends_on "sqlite"
  depends_on "mecab" if MacOS.version >= :mountain_lion
  depends_on :python if MacOS.version <= :snow_leopard # for python glue code

  def install
    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make"
      # `make test` currently fails. Reported upstream:
      # https://github.com/konoha-project/konoha3/issues/438
      system "make", "test" if build.with? "test"
      system "make", "install"
    end
  end

  test do
    (testpath/"test").write "System.p(\"Hello World!\");"
    output = shell_output("#{bin}/konoha #{testpath}/test")
    assert_match "(test:1) Hello World!", output
  end
end
