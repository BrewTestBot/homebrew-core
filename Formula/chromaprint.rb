class Chromaprint < Formula
  desc "Core component of the AcoustID project (Audio fingerprinting)"
  homepage "https://acoustid.org/chromaprint"
  url "https://bitbucket.org/acoustid/chromaprint/downloads/chromaprint-1.3.tar.gz"
  sha256 "3dc3ff97abdce63abc1f52d5f5f8e72c22f9a690dd6625271aa96d3a585b695a"
  revision 2

  bottle do
    cellar :any
    sha256 "754258c5927d7e5f7894e4747ece4ea93da369b77bf34d7c4b212569db4a7a09" => :sierra
    sha256 "05fa1392a131c834416a04943216724b534c5b5a5ed059fb4f591dd46aaae7c4" => :el_capitan
    sha256 "21b0e47b870d43696ded14ea40a7022b98fdd1b08f0057a14a966b4caa4103fe" => :yosemite
    sha256 "611f98dcc4855ad23b30ae5db399e5c6c6b659dc31fb09d5c7e573002e335448" => :mavericks
  end

  depends_on "cmake" => :build

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end
end
