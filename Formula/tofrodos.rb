class Tofrodos < Formula
  desc "Converts DOS <-> UNIX text files, alias tofromdos"
  homepage "https://www.thefreecountry.com/tofrodos/"
  url "http://tofrodos.sourceforge.net/download/tofrodos-1.7.13.tar.gz"
  sha256 "3457f6f3e47dd8c6704049cef81cb0c5a35cc32df9fe800b5fbb470804f0885f"

  bottle do
    cellar :any_skip_relocation
    rebuild 1
    sha256 "b47a04446721f0e1c6426d9f92c40ca3500e62e8afbd1e2f8a61ccd22539135a" => :yosemite
  end

  def install
    cd "src" do
      system "make"
      bin.install %w[todos fromdos]
      man1.install "fromdos.1"
      man1.install_symlink "fromdos.1" => "todos.1"
    end
  end
end
