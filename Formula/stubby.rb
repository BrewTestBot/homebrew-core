class Stubby < Formula
  desc "DNS privacy enabled stub resolver service based on getdns"
  homepage "https://dnsprivacy.org/wiki/display/DP/DNS+Privacy+Daemon+-+Stubby"
  url "https://github.com/getdnsapi/stubby/archive/v0.2.6.tar.gz"
  sha256 "634b0b9fb8f36416e210fa65800a6c1672bcf9f4f276a042ccf89567ad8ef781"
  head "https://github.com/getdnsapi/stubby.git", :branch => "develop"

  bottle do
    rebuild 1
    sha256 "a86c0d413ca2a7e0f79e5e1bca9d90ad0e44199277e0f7be408f07afaeb0f6c4" => :mojave
    sha256 "168eba28ca6a51915f6434b13f0cf4e7c06fbabf881c596d649f3ae242851ec1" => :high_sierra
    sha256 "7a3c6595d7dcab3e6a1d240fd7a722d35e14e1d434e4b9489ddfdab78f949a14" => :sierra
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "getdns"
  depends_on "libyaml"

  def install
    system "autoreconf", "-fiv"
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--sysconfdir=#{etc}"
    system "make", "install"
  end

  plist_options :startup => true, :manual => "sudo stubby -C #{HOMEBREW_PREFIX}/etc/stubby/stubby.yml"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-/Apple/DTD PLIST 1.0/EN" "http:/www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>KeepAlive</key>
        <true/>
        <key>RunAtLoad</key>
        <true/>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/stubby</string>
          <string>-C</string>
          <string>#{etc}/stubby/stubby.yml</string>
        </array>
        <key>StandardErrorPath</key>
        <string>#{var}/log/stubby/stubby.log</string>
        <key>StandardOutPath</key>
        <string>#{var}/log/stubby/stubby.log</string>
      </dict>
    </plist>
  EOS
  end

  test do
    assert_predicate etc/"stubby/stubby.yml", :exist?
    (testpath/"stubby_test.yml").write <<~EOS
      resolution_type: GETDNS_RESOLUTION_STUB
      dns_transport_list:
        - GETDNS_TRANSPORT_TLS
        - GETDNS_TRANSPORT_UDP
        - GETDNS_TRANSPORT_TCP
      listen_addresses:
        - 127.0.0.1@5553
      idle_timeout: 0
      upstream_recursive_servers:
        - address_data: 145.100.185.15
        - address_data: 145.100.185.16
        - address_data: 185.49.141.37
    EOS
    output = shell_output("#{bin}/stubby -i -C stubby_test.yml")
    assert_match "bindata for 145.100.185.15", output
    pid = fork do
      exec "#{bin}/stubby", "-C", testpath/"stubby_test.yml"
    end
    begin
      sleep 2
      output = shell_output("dig @127.0.0.1 -p 5553 getdnsapi.net")
      assert_match "status: NOERROR", output
    ensure
      Process.kill 9, pid
      Process.wait pid
    end
  end
end
