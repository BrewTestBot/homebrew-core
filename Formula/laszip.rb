class Laszip < Formula
  desc "Lossless LiDAR compression"
  homepage "http://www.laszip.org/"
  url "https://github.com/LASzip/LASzip/releases/download/3.1.0/laszip-src-3.1.0.tar.gz"
  sha256 "24376968294b01ca0868f7ec13b80ae7ec3f831e64c0b4397103a6bef1f3b726"
  head "https://github.com/LASzip/LASzip.git"

  bottle do
    cellar :any
    sha256 "26635adc73522f43a5e6f27565e6b9cf9e75320d75155aad816aae5b583b6bc7" => :high_sierra
    sha256 "9b3799014035a92909269d87f3756d98c83922c708c2ae0b2ac8f2c0ccc6f20e" => :sierra
    sha256 "3544d8dd1e7db052d685ecc588803dd8723172df160619d7451afe6ede7b884e" => :el_capitan
    sha256 "e757a001cce1bacae92297fedb006cd40a91e20035e84e071664d89a55862af5" => :yosemite
    sha256 "7691838134d631d123cfba57a05ab17213517442457454c0967b372d5cb7f0c3" => :mavericks
  end

  depends_on "cmake" => :build

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
    pkgshare.install "example"
  end

  test do
    system ENV.cxx, pkgshare/"example/laszipdllexample.cpp", "-L#{lib}",
                    "-llaszip", "-llaszip_api", "-Wno-format", "-o", "test"
    assert_match "LASzip DLL", shell_output("./test -h 2>&1", 1)
  end
end
