class ArchiSteamFarm < Formula
  desc "ASF is a C# application that allows you to farm steam cards"
  homepage "https://github.com/JustArchi/ArchiSteamFarm"
  url "https://github.com/JustArchi/ArchiSteamFarm/releases/download/2.3.1.8/ASF.zip"
  version "2.3.1.8"
  sha256 "169a2f6deaf582646781089d301a03208cbbc127a9f924a5815ab9ba8707cb19"

  bottle do
    cellar :any_skip_relocation
    sha256 "7a2e792ce756de3ca77ae63d00073da56b7ba0b599f2583b8e286ba60be63c97" => :sierra
    sha256 "0054489a26c12f9379ad9f79ac959c07e9b4a6d0a387e08400ad8cb978a602d8" => :el_capitan
    sha256 "0054489a26c12f9379ad9f79ac959c07e9b4a6d0a387e08400ad8cb978a602d8" => :yosemite
  end

  depends_on "mono"

  def install
    libexec.install "ASF.exe"
    (bin/"asf").write <<-EOS.undent
      #!/bin/bash
      mono #{libexec}/ASF.exe "$@"
    EOS

    etc.install "config" => "asf"
    libexec.install_symlink etc/"asf" => "config"
  end

  def caveats; <<-EOS.undent
    Config: #{etc}/asf/
    EOS
  end

  test do
    assert_match "ASF V#{version}", shell_output("#{bin}/asf --client")
  end
end
