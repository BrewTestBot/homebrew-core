class Mmseqs2 < Formula
  desc "Software suite for very fast protein sequence search and clustering"
  homepage "https://mmseqs.org/"
  url "https://github.com/soedinglab/MMseqs2/archive/2-23394.tar.gz"
  version "2-23394"
  sha256 "36763fff4c4de1ab6cfc37508a2ee9bd2f4b840e0c9415bd1214280f67b67072"

  bottle do
    cellar :any
    sha256 "9d90d7709a4ea65f6baa5fcd1bc5c88e4dfafa806502786d17145490b5115ac2" => :high_sierra
    sha256 "c99a074e4c5e7da8dc7b4f7a3ee6deb16446cb2b6dfbb85b3d6b388dd7f9d33b" => :sierra
    sha256 "dc00e4c500c2c2912f049527dfbcb9f3aa2dfe6f96ab31fea7c605f155e05117" => :el_capitan
  end

  depends_on "cmake" => :build
  depends_on "gcc"

  cxxstdlib_check :skip

  fails_with :clang # needs OpenMP support

  resource "documentation" do
    url "https://github.com/soedinglab/MMseqs2.wiki.git",
        :revision => "6dbd3666edb64fc71173ee714014e88c1ebe2dfc"
  end

  def install
    # version information is read from git by default
    # next MMseqs2 version will include a cmake flag so we do not need this hack
    inreplace "src/version/Version.cpp", /.+/m, "const char *version = \"#{version}\";"

    args = *std_cmake_args << "-DHAVE_TESTS=0" << "-DHAVE_MPI=0"

    args << "-DHAVE_SSE4_1=1" if build.bottle?

    system "cmake", ".", *args
    system "make", "install"

    resource("documentation").stage { doc.install Dir["*"] }
    pkgshare.install "examples"
    bash_completion.install "util/bash-completion.sh" => "mmseqs.sh"
  end

  def caveats
    unless Hardware::CPU.sse4?
      "MMseqs2 requires at least SSE4.1 CPU instruction support. The binary will not work correctly."
    end
  end

  test do
    system "#{bin}/mmseqs", "createdb", "#{pkgshare}/examples/QUERY.fasta", "q"
    system "#{bin}/mmseqs", "cluster", "q", "res", "tmp", "-s", "1", "--cascaded"
  end
end
