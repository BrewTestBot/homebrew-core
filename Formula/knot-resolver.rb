class KnotResolver < Formula
  desc "Minimalistic, caching, DNSSEC-validating DNS resolver"
  homepage "https://www.knot-resolver.cz"
  url "https://secure.nic.cz/files/knot-resolver/knot-resolver-3.2.1.tar.xz"
  sha256 "d1396888ec3a63f19dccdf2b7dbcb0d16a5d8642766824b47f4c21be90ce362b"
  revision 1
  head "https://gitlab.labs.nic.cz/knot/knot-resolver.git"

  bottle do
    rebuild 1
    sha256 "f5f6c40bd0aca777361059a501fc30a1d8485bd9e9735acdb6ab0f5ee056860b" => :catalina
    sha256 "ce9df928898820cb0e9af1115d1064307fc2a41a39029b924ee063e0cbd5945b" => :mojave
    sha256 "7160763c1178ddcb9d44a4c062d75c816e7607abaf2569915757afcc7b8d8d7a" => :high_sierra
  end

  depends_on "cmocka" => :build
  depends_on "pkg-config" => :build
  depends_on "gnutls"
  depends_on "knot"
  depends_on "libuv"
  depends_on "lmdb"
  depends_on "luajit"
  depends_on "nettle"

  def install
    # Since we don't run `make install` or `make etc-install`, we need to
    # install root.hints manually before running `make check`.
    cp "etc/root.hints", buildpath
    (etc/"kresd").install "root.hints"

    %w[all lib-install daemon-install client-install modules-install
       check].each do |target|
      system "make", target, "PREFIX=#{prefix}", "ETCDIR=#{etc}/kresd"
    end

    cp "etc/config.personal", "config"
    inreplace "config", /^\s*user\(/, "-- user("
    (etc/"kresd").install "config"

    (etc/"kresd").install "etc/root.hints"
    (etc/"kresd").install "etc/icann-ca.pem"

    (buildpath/"root.keys").write(root_keys)
    (var/"kresd").install "root.keys"
  end

  # DNSSEC root anchor published by IANA (https://www.iana.org/dnssec/files)
  def root_keys; <<~EOS
    . IN DS 20326 8 2 e06d44b80b8f1d39a95c0b0d7c65d08458e880409bbc683457104237c7f8ec8d
  EOS
  end

  plist_options :startup => true

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>WorkingDirectory</key>
      <string>#{var}/kresd</string>
      <key>RunAtLoad</key>
      <true/>
      <key>ProgramArguments</key>
      <array>
        <string>#{sbin}/kresd</string>
        <string>-c</string>
        <string>#{etc}/kresd/config</string>
        <string>-f</string>
        <string>1</string>
      </array>
      <key>StandardInPath</key>
      <string>/dev/null</string>
      <key>StandardOutPath</key>
      <string>/dev/null</string>
      <key>StandardErrorPath</key>
      <string>#{var}/log/kresd.log</string>
    </dict>
    </plist>
  EOS
  end

  test do
    system sbin/"kresd", "--version"
  end
end
