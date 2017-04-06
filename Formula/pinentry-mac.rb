class PinentryMac < Formula
  desc "Pinentry for GPG on Mac"
  homepage "https://github.com/GPGTools/pinentry-mac"
  url "https://github.com/GPGTools/pinentry-mac/archive/v0.9.4.tar.gz"
  sha256 "037ebb010377d3a3879ae2a832cefc4513f5c397d7d887d7b86b4e5d9a628271"
  head "https://github.com/GPGTools/pinentry-mac.git"

  bottle do
    cellar :any_skip_relocation
    rebuild 1
    sha256 "aca39c1787439671c36d2fe8a39a34956c4908a18f4122516b09302ca928ab24" => :sierra
    sha256 "76617fe7fd65543c0e04d492fa71490379c9afb5e6e981611d26183181f7f3ec" => :el_capitan
    sha256 "121788a1fa0006ccc669f310b47792f72a7bda9fc24a745fd32df1be3ca5970b" => :yosemite
  end

  depends_on :xcode => :build

  def install
    system "make"
    prefix.install "build/Release/pinentry-mac.app"
    bin.write_exec_script "#{prefix}/pinentry-mac.app/Contents/MacOS/pinentry-mac"
  end

  def caveats; <<-EOS.undent
    You can now set this as your pinentry program like

    ~/.gnupg/gpg-agent.conf
        pinentry-program #{HOMEBREW_PREFIX}/bin/pinentry-mac
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/pinentry-mac --version")
  end
end
