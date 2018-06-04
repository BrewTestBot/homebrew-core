class TarsnapGui < Formula
  desc "Cross-platform GUI for the Tarsnap command-line client"
  homepage "https://github.com/Tarsnap/tarsnap-gui/wiki"
  url "https://github.com/Tarsnap/tarsnap-gui/archive/v1.0.1.tar.gz"
  sha256 "502e53a4eacb2795bfbe62b9e6ef236cce6fdb43cb15153c0fc4ad61c161eb97"
  head "https://github.com/Tarsnap/tarsnap-gui.git"

  bottle do
    sha256 "95ce5a2a28ff6981d569ad264cd7ef97bfbb20a808309f199b4044d50ea59e9f" => :high_sierra
    sha256 "65333d2097628d889e78ecb717a11de647f0d11058dd8ce7f263c573e828b54e" => :sierra
    sha256 "2963c8328a97832660467d27207bdb92340b7e1d10c4f70b552a56b433db5c5d" => :el_capitan
    sha256 "6c33861a277da0171c26ee389ab5e3f1d2277f3e577f18446e816909680cf9fb" => :yosemite
  end

  depends_on "qt"
  depends_on "tarsnap"

  def install
    system "qmake"
    system "make"
    system "macdeployqt", "Tarsnap.app"
    prefix.install "Tarsnap.app"
  end

  test do
    system "#{opt_prefix}/Tarsnap.app/Contents/MacOS/Tarsnap", "--version"
  end
end
