class Ldc < Formula
  desc "Portable D programming language compiler"
  homepage "https://wiki.dlang.org/LDC"
  revision 1

  stable do
    url "https://github.com/ldc-developers/ldc/releases/download/v1.1.1/ldc-1.1.1-src.tar.gz"
    sha256 "3d35253a76288a78939fea467409462f0b87461ffb89550eb0d9958e59eb7e97"

    resource "ldc-lts" do
      url "https://github.com/ldc-developers/ldc/releases/download/v0.17.3/ldc-0.17.3-src.tar.gz"
      sha256 "325bd540f7eb71c309fa0ee9ef6d196a75ee2c3ccf323076053e6b7b295c2dad"
    end

    # Remove for lts > 0.17.3
    # Upstream commit from 26 Feb 2017 "Fix build for LLVM 4.0"
    # See https://github.com/ldc-developers/ldc/pull/2017
    resource "ldc-lts-patch" do
      url "https://github.com/ldc-developers/ldc/commit/4847d8a.patch"
      sha256 "7d93765898ce5501eb9660d76e9837682eb0dd38708fa640b6b443b02577a172"
    end
  end

  bottle do
    rebuild 1
    sha256 "9129855a97858f48be7d833937e4841717eaf33f0ce222740f83a970c4faa239" => :sierra
    sha256 "b2180ae43c4f49e45789767207090279600b7c1db0e0a1d608bc2f2a254e5f77" => :el_capitan
    sha256 "2c45fc963845512a4f42a29113d1e39a59b4eae6d79e8e3252f961af0c11c580" => :yosemite
  end

  devel do
    url "https://github.com/ldc-developers/ldc/releases/download/v1.2.0-beta1/ldc-1.2.0-beta1-src.tar.gz"
    sha256 "0fd90d786254665b3e846b9a92cfd0b4e9c9c1840ebd26ddc0c0a0d4cd8726b9"
    version "1.2.0-beta1"

    resource "ldc-lts" do
      url "https://github.com/ldc-developers/ldc/releases/download/v0.17.3/ldc-0.17.3-src.tar.gz"
      sha256 "325bd540f7eb71c309fa0ee9ef6d196a75ee2c3ccf323076053e6b7b295c2dad"
    end

    # Same as in stable
    resource "ldc-lts-patch" do
      url "https://github.com/ldc-developers/ldc/commit/4847d8a.patch"
      sha256 "7d93765898ce5501eb9660d76e9837682eb0dd38708fa640b6b443b02577a172"
    end
  end

  head do
    url "https://github.com/ldc-developers/ldc.git", :shallow => false

    resource "ldc-lts" do
      url "https://github.com/ldc-developers/ldc.git", :shallow => false, :branch => "ltsmaster"
    end
  end

  needs :cxx11

  depends_on "cmake" => :build
  depends_on "llvm"
  depends_on "libconfig"

  def install
    ENV.cxx11
    (buildpath/"ldc-lts").install resource("ldc-lts")

    # Remove for ldc-lts > 0.7.3
    if build.stable? || build.devel?
      resource("ldc-lts-patch").stage do
        system "patch", "-p1", "-i", Pathname.pwd/"4847d8a.patch", "-d",
                        buildpath/"ldc-lts"
      end
    end

    cd "ldc-lts" do
      mkdir "build" do
        args = std_cmake_args + %W[
          -DLLVM_ROOT_DIR=#{Formula["llvm"].opt_prefix}
        ]
        system "cmake", "..", *args
        system "make"
      end
    end
    mkdir "build" do
      args = std_cmake_args + %W[
        -DLLVM_ROOT_DIR=#{Formula["llvm"].opt_prefix}
        -DINCLUDE_INSTALL_DIR=#{include}/dlang/ldc
        -DD_COMPILER=#{buildpath}/ldc-lts/build/bin/ldmd2
      ]

      system "cmake", "..", *args
      system "make"
      system "make", "install"
    end
  end

  test do
    (testpath/"test.d").write <<-EOS.undent
      import std.stdio;
      void main() {
        writeln("Hello, world!");
      }
    EOS

    system bin/"ldc2", "-flto=full", "test.d"

    assert_match "Hello, world!", shell_output("./test")
    system bin/"ldmd2", "test.d"
    assert_match "Hello, world!", shell_output("./test")
  end
end
