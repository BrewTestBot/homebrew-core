class Caddy < Formula
  desc "Alternative general-purpose HTTP/2 web server"
  homepage "https://caddyserver.com/"
  url "https://github.com/caddyserver/caddy/archive/v1.0.4.tar.gz"
  sha256 "bf81245d2b347c89a8e8aa358a224b722d55cb6e1c266bbdffbe6acc54d130a5"
  head "https://github.com/caddyserver/caddy.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "7a94ee9de2a659903942ce947ef1c8353de572dbf75952775a4f8c8fe5b2919b" => :catalina
    sha256 "71cdee31fbe932ac7c48482bef34b5e8f95d148e14796b990494462ac334b9c0" => :mojave
    sha256 "1b378b3ec18d7c9f97dc6fe52a5706e590ec3f329a755361a094228312b76fca" => :high_sierra
    sha256 "17356067c9bbeb67c0b5ac218c21a066a90620cb9b6fb806733a38b27be73eff" => :sierra
  end

  depends_on "go" => :build

  def install
    ENV["GOOS"] = "darwin"
    ENV["GOARCH"] = "amd64"

    (buildpath/"src/github.com/caddyserver").mkpath
    ln_s buildpath, "src/github.com/caddyserver/caddy"

    system "go", "build", "-ldflags",
           "-X github.com/caddyserver/caddy/caddy/caddymain.gitTag=#{version}",
           "-o", bin/"caddy", "github.com/caddyserver/caddy/caddy"
  end

  plist_options :manual => "caddy -conf #{HOMEBREW_PREFIX}/etc/Caddyfile"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>KeepAlive</key>
        <true/>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/caddy</string>
          <string>-conf</string>
          <string>#{etc}/Caddyfile</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
      </dict>
    </plist>
  EOS
  end

  test do
    begin
      io = IO.popen("#{bin}/caddy")
      sleep 2
    ensure
      Process.kill("SIGINT", io.pid)
      Process.wait(io.pid)
    end

    io.read =~ /0\.0\.0\.0:2015/
  end
end
