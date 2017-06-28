class Doxygen < Formula
  desc "Generate documentation for several programming languages"
  homepage "http://www.doxygen.org/"
  revision 1
  head "https://github.com/doxygen/doxygen.git"

  stable do
    url "https://ftp.stack.nl/pub/users/dimitri/doxygen-1.8.13.src.tar.gz"
    sha256 "af667887bd7a87dc0dbf9ac8d86c96b552dfb8ca9c790ed1cbffaa6131573f6b"

    # Remove for > 1.8.13
    # "Bug 776791 - [1.8.13 Regression] Segfault building the breathe docs"
    # Upstream PR from 4 Jan 2017 https://github.com/doxygen/doxygen/pull/555
    patch do
      url "https://github.com/doxygen/doxygen/commit/0f02761a158a5e9ddbd5801682482af8986dbc35.patch?full_index=1"
      sha256 "6705eb83b419ad9a696290c624b8ff363ff39b94b250008d0ef36200254c2a08"
    end
  end

  bottle do
    cellar :any_skip_relocation
    rebuild 2
    sha256 "108dfd74444cec5c9cfed87c5fccebd53cfe9cc8704702877806c796b11400e8" => :sierra
    sha256 "242bdcb4e10ca6c9433d1428c1e52d47c76f188ce381510391fb1004944fb236" => :el_capitan
    sha256 "e2712c4c65f56993717330469e6b1e341b126eee83595c924e09eac546865061" => :yosemite
  end

  option "with-graphviz", "Build with dot command support from Graphviz."
  option "with-qt", "Build GUI frontend with Qt support."
  option "with-llvm", "Build with libclang support."

  deprecated_option "with-dot" => "with-graphviz"
  deprecated_option "with-doxywizard" => "with-qt"
  deprecated_option "with-libclang" => "with-llvm"
  deprecated_option "with-qt5" => "with-qt"

  depends_on "cmake" => :build
  depends_on "graphviz" => :optional
  depends_on "qt" => :optional
  depends_on "llvm" => :optional

  def install
    args = std_cmake_args << "-DCMAKE_OSX_DEPLOYMENT_TARGET:STRING=#{MacOS.version}"
    args << "-Dbuild_wizard=ON" if build.with? "qt"
    args << "-Duse_libclang=ON -DLLVM_CONFIG=#{Formula["llvm"].opt_bin}/llvm-config" if build.with? "llvm"

    mkdir "build" do
      system "cmake", "..", *args
      system "make"
    end
    bin.install Dir["build/bin/*"]
    man1.install Dir["doc/*.1"]
  end

  test do
    system "#{bin}/doxygen", "-g"
    system "#{bin}/doxygen", "Doxyfile"
  end
end
