class Emscripten < Formula
  desc "LLVM bytecode to JavaScript compiler"
  homepage "https://kripken.github.io/emscripten-site/"

  stable do
    version "1.36.14"
    url "https://github.com/kripken/emscripten/archive/#{version}.tar.gz"
    sha256 "89febe6c56c36ded3a6323d40342196d961eb1a7878b32912a649734962cb5ee"

    resource "fastcomp" do
      url "https://github.com/kripken/emscripten-fastcomp/archive/#{version}.tar.gz"
      sha256 "3fc361151790574c7dfe4466a32dcb505abc930cf48dd941463880924228a3d5"
    end

    resource "fastcomp-clang" do
      url "https://github.com/kripken/emscripten-fastcomp-clang/archive/#{version}.tar.gz"
      sha256 "d33574f378acde198a2407a88cfa2725d8853dee535f982ec5fac92b4180f3aa"
    end

    depends_on "cmake" => :build
  end

  bottle do
    sha256 "3585fd9a6d92e461613b03cb42758ade8e811ad603b290e6743983500aaf9f30" => :sierra
    sha256 "74dd27fe744335b4be1cc3d9f670c87a285bc0b1b08fb26f343d532214328b07" => :el_capitan
    sha256 "e8b1b317bf338d70984487460fb74fb5c7216f136314b3c642eb04bea7e2ebdb" => :yosemite
  end

  head do
    url "https://github.com/kripken/emscripten.git", :branch => "master"

    resource "fastcomp" do
      url "https://github.com/kripken/emscripten-fastcomp.git", :branch => "master"
    end

    resource "fastcomp-clang" do
      url "https://github.com/kripken/emscripten-fastcomp-clang.git", :branch => "master"
    end

    depends_on "cmake" => :build
  end

  needs :cxx11

  depends_on :python if MacOS.version <= :snow_leopard
  depends_on "node"
  depends_on "closure-compiler" => :optional
  depends_on "yuicompressor"

  def install
    ENV.cxx11
    # OSX doesn't provide a "python2" binary so use "python" instead.
    python2_shebangs = `grep --recursive --files-with-matches ^#!/usr/bin/.*python2$ #{buildpath}`
    python2_shebang_files = python2_shebangs.lines.sort.uniq
    python2_shebang_files.map! { |f| Pathname(f.chomp) }
    python2_shebang_files.reject! &:symlink?
    inreplace python2_shebang_files, %r{^(#!/usr/bin/.*python)2$}, "\\1"

    # All files from the repository are required as emscripten is a collection
    # of scripts which need to be installed in the same layout as in the Git
    # repository.
    libexec.install Dir["*"]

    (buildpath/"fastcomp").install resource("fastcomp")
    (buildpath/"fastcomp/tools/clang").install resource("fastcomp-clang")

    cmake_args = std_cmake_args.reject { |s| s["CMAKE_INSTALL_PREFIX"] }
    cmake_args = [
      "-DCMAKE_BUILD_TYPE=Release",
      "-DCMAKE_INSTALL_PREFIX=#{libexec}/llvm",
      "-DLLVM_TARGETS_TO_BUILD='X86;JSBackend'",
      "-DLLVM_INCLUDE_EXAMPLES=OFF",
      "-DLLVM_INCLUDE_TESTS=OFF",
      "-DCLANG_INCLUDE_TESTS=OFF",
      "-DOCAMLFIND=/usr/bin/false",
      "-DGO_EXECUTABLE=/usr/bin/false",
    ]

    mkdir "fastcomp/build" do
      system "cmake", "..", *cmake_args
      system "make"
      system "make", "install"
    end

    %w[em++ em-config emar emcc emcmake emconfigure emlink.py emmake
       emranlib emrun emscons].each do |emscript|
      bin.install_symlink libexec/emscript
    end
  end

  def caveats; <<-EOS.undent
    Manually set LLVM_ROOT to
      #{opt_libexec}/llvm/bin
    in ~/.emscripten after running `emcc` for the first time.
    EOS
  end

  test do
    system "#{libexec}/llvm/bin/llvm-config", "--version"
  end
end
