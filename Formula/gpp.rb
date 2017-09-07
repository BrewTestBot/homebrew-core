class Gpp < Formula
  desc "General-purpose preprocessor with customizable syntax"
  homepage "http://en.nothingisreal.com/wiki/GPP"
  url "https://files.nothingisreal.com/software/gpp/gpp-2.25.tar.bz2"
  sha256 "16ba9329208f587f96172f951ad3d24a81afea6a5b7836fe87955726eacdd19f"

  bottle do
    cellar :any_skip_relocation
    rebuild 1
    sha256 "7b905243827e6b5877c8af1f13b6fb3b79c07341059fdb1b6a382fe1286d580b" => :sierra
    sha256 "6925eb92be766ed9fe61a9a98dc7bc3c22793079abf63f462cb7001017cac28c" => :el_capitan
    sha256 "e9bb30f85bd24890f97160649a3ed9ef8081d0e39154226487b29e4c58d154ab" => :yosemite
    sha256 "90463e69adac31b694bbcac3e90ad494bb8e4ef4927d1a04e3a7246b87c0d55d" => :mavericks
    sha256 "bfcf6ef95b33a600dc6471b4f80e3dbb8e4f4e3cf13aa21b67990576ade35414" => :mountain_lion
  end

  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}", "--mandir=#{man}"
    system "make"
    system "make", "check"
    system "make", "install"
  end
end
