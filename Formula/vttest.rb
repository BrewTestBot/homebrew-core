class Vttest < Formula
  desc "Test compatibility of VT100-compatible terminals"
  homepage "https://invisible-island.net/vttest/"
  url "https://invisible-mirror.net/archives/vttest/vttest-20200303.tgz"
  sha256 "49aa5828f8827f22fdae8c49cbc4fc78e9abb46d7670167985a7c079c6f547bc"

  bottle do
    cellar :any_skip_relocation
    sha256 "91afb7cae0494fc2da73e6e66121e2482d5673b69b2ce3e99792e79b01f8a98b" => :catalina
    sha256 "a8dbf4d1fa88673fc6aba2c41b13ff917be9669220852bd4a2295d44c60c8f7a" => :mojave
    sha256 "8d3bd4169069a0e8b87b9715db1d6518acb4e335157f7be25b867a48c13d023f" => :high_sierra
    sha256 "206744ef6b93ed8a6be0921ebd964b4e8e03e92b057afbcb9dff0806bf6ef747" => :sierra
  end

  def install
    system "./configure", "--prefix=#{prefix}", "--mandir=#{man}"
    system "make"
    system "make", "install"
  end

  test do
    assert_match version.to_s, shell_output(bin/"vttest -V")
  end
end
