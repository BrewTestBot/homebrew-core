class Launchdns < Formula
  desc "Mini DNS server designed solely to route queries to localhost"
  homepage "https://github.com/josh/launchdns"
  url "https://github.com/josh/launchdns/archive/v1.0.3.tar.gz"
  sha256 "c34bab9b4f5c0441d76fefb1ee16cb0279ab435e92986021c7d1d18ee408a5dd"
  revision 1
  head "https://github.com/josh/launchdns.git"

  bottle do
    cellar :any_skip_relocation
    rebuild 1
    sha256 "17ec4b863a84ed628d16ef2a642333b609b8cdc98d53d7338bc9fb42ec8e6a15" => :high_sierra
    sha256 "9a9fcd715d808d0d7064c249c27534f320798f73caccdf80775711d2d7d8208b" => :sierra
    sha256 "7592856e53b1981d9be5b26354150f7652dac63df0fdb1aea226b4ec47c9f423" => :el_capitan
  end

  depends_on :macos => :yosemite

  def install
    ENV["PREFIX"] = prefix
    system "./configure", "--with-launch-h", "--with-launch-h-activate-socket"
    system "make", "install"

    (prefix/"etc/resolver/localhost").write("nameserver 127.0.0.1\nport 55353\n")
  end

  def caveats; <<~EOS
    To have *.localhost resolved to 127.0.0.1:
      sudo ln -s #{HOMEBREW_PREFIX}/etc/resolver /etc
    EOS
  end

  plist_options :manual => "launchdns"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/launchdns</string>
          <string>--socket=Listeners</string>
          <string>--timeout=30</string>
        </array>
        <key>Sockets</key>
        <dict>
          <key>Listeners</key>
          <dict>
            <key>SockType</key>
            <string>dgram</string>
            <key>SockNodeName</key>
            <string>127.0.0.1</string>
            <key>SockServiceName</key>
            <string>55353</string>
          </dict>
        </dict>
        <key>StandardErrorPath</key>
        <string>#{var}/log/launchdns.log</string>
        <key>StandardOutPath</key>
        <string>#{var}/log/launchdns.log</string>
      </dict>
    </plist>
    EOS
  end

  test do
    output = shell_output("#{bin}/launchdns --version")
    assert_no_match(/without socket activation/, output)
    system bin/"launchdns", "-p0", "-t1"
  end
end
