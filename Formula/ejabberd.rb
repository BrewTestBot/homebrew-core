class Ejabberd < Formula
  desc "XMPP application server"
  homepage "https://www.ejabberd.im"

  stable do
    url "https://www.process-one.net/downloads/ejabberd/16.04/ejabberd-16.04.tgz"
    sha256 "3d964fe74e438253c64c8498eb7465d2440823614a23df8d33bdf40126d72cc3"

    resource "cache_tab" do
      url "https://github.com/processone/cache_tab.git",
        :tag => "1.0.2",
        :revision => "aeb255793d1ca48a147d8b5f22c3bc09ddb6ba87"
    end

    resource "eredis" do
      url "https://github.com/wooga/eredis.git",
        :tag => "v1.0.8",
        :revision => "cbc013f516e464706493c01662e5e9dd82d1db01"
    end

    resource "esip" do
      url "https://github.com/processone/esip.git",
        :tag => "1.0.4",
        :revision => "9b57b40bd1195d097a9dca71c1dabc9230dfed8c"
    end

    resource "ezlib" do
      url "https://github.com/processone/ezlib.git",
        :tag => "1.0.1",
        :revision => "85617df345589c0b6eca5d4100eb04ac4bffe3d5"
    end

    resource "fast_tls" do
      url "https://github.com/processone/fast_tls.git",
        :tag => "1.0.3",
        :revision => "ccc6a5c52764f1a0c355ad16c4ae06b11194e4b7"
    end

    resource "fast_xml" do
      url "https://github.com/processone/fast_xml.git",
        :tag => "1.1.3",
        :revision => "f6f21a56211afd9d99670ac4953a2d5c6163e4e0"
    end

    resource "fast_yaml" do
      url "https://github.com/processone/fast_yaml.git",
        :tag => "1.0.3",
        :revision => "9a3b510d7cf3581d7211ad13c307e2be60abdc4e"
    end

    resource "iconv" do
      url "https://github.com/processone/iconv.git",
        :tag => "1.0.0",
        :revision => "514703b3a5517a7a921ad5ce3e83b76df2bd70f0"
    end

    resource "jiffy" do
      url "https://github.com/davisp/jiffy.git",
        :tag => "0.14.7",
        :revision => "6303ff98aaa3fce625038c8b7af2aa8b802f4742"
    end

    resource "lager" do
      url "https://github.com/basho/lager.git",
        :tag => "3.0.3",
        :revision => "c7737da3a1892dbee0eb7554e236e1b041809269"
    end

    resource "p1_mysql" do
      url "https://github.com/processone/p1_mysql.git",
        :tag => "1.0.1",
        :revision => "a13606026f3ee8862c7d7c9b31ad2faf5ee8031a"
    end

    resource "p1_oauth2" do
      url "https://github.com/processone/p1_oauth2.git",
        :tag => "0.6.1",
        :revision => "34f9b20fd68134a4646130bdcf1abf320f815a00"
    end

    resource "p1_pgsql" do
      url "https://github.com/processone/p1_pgsql.git",
        :tag => "1.1.0",
        :revision => "1cefac417342c71a08a08043b1b743e72d4ddc12"
    end

    resource "p1_utils" do
      url "https://github.com/processone/p1_utils.git",
        :tag => "1.0.4",
        :revision => "e8d35fa5accd9a748bb8ac4942edcfa45be09ec3"
    end

    resource "p1_xmlrpc" do
      url "https://github.com/processone/p1_xmlrpc.git",
        :tag => "1.15.1",
        :revision => "6dface5a00da4cd0b0084a253075b5573336c0bb"
    end

    resource "sqlite3" do
      url "https://github.com/processone/erlang-sqlite3.git",
        :tag => "v1.1.4",
        :revision => "9a5bd3b86bf86790cc0571cbb2e26da4660fb41c"
    end

    resource "stringprep" do
      url "https://github.com/processone/stringprep.git",
        :tag => "1.0.3",
        :revision => "5005ecbe503ae8b55d3ee81dc4e4db1193c216e2"
    end

    resource "stun" do
      url "https://github.com/processone/stun.git",
        :tag => "1.0.3",
        :revision => "653943e6d0cc0f4803a9c3f014955f02f7b96bcd"
    end
  end

  bottle do
    sha256 "8770ba2056ecc794a5aa8265784c9febe1ae0e95ad0c160649ff46fe625e3d82" => :el_capitan
    sha256 "c5210d8b0481ed205b9525e09aec741c037c99cf755586bfcfbb326f1ecbacb5" => :yosemite
    sha256 "b669c053987205cb897d18f3b0640c20f54e511aa54d37666e69582dbb6f90b6" => :mavericks
  end

  head do
    url "https://github.com/processone/ejabberd.git"

    depends_on "automake" => :build
    depends_on "autoconf" => :build

    resource "cache_tab" do
      url "https://github.com/processone/cache_tab.git"
    end

    resource "eredis" do
      url "https://github.com/wooga/eredis.git"
    end

    resource "esip" do
      url "https://github.com/processone/esip.git"
    end

    resource "ezlib" do
      url "https://github.com/processone/ezlib.git"
    end

    resource "fast_tls" do
      url "https://github.com/processone/fast_tls.git"
    end

    resource "fast_xml" do
      url "https://github.com/processone/fast_xml.git"
    end

    resource "fast_yaml" do
      url "https://github.com/processone/fast_yaml.git"
    end

    resource "iconv" do
      url "https://github.com/processone/iconv.git"
    end

    resource "jiffy" do
      url "https://github.com/davisp/jiffy.git"
    end

    resource "lager" do
      url "https://github.com/basho/lager.git"
    end

    resource "p1_mysql" do
      url "https://github.com/processone/p1_mysql.git"
    end

    resource "p1_oauth2" do
      url "https://github.com/processone/p1_oauth2.git"
    end

    resource "p1_pgsql" do
      url "https://github.com/processone/p1_pgsql.git"
    end

    resource "p1_utils" do
      url "https://github.com/processone/p1_utils.git"
    end

    resource "p1_xmlrpc" do
      url "https://github.com/processone/p1_xmlrpc.git"
    end

    resource "sqlite3" do
      url "https://github.com/processone/erlang-sqlite3.git"
   end

    resource "stringprep" do
      url "https://github.com/processone/stringprep.git"
    end

    resource "stun" do
      url "https://github.com/processone/stun.git"
    end
  end

  option "32-bit"

  depends_on "openssl"
  depends_on "erlang"
  depends_on "libyaml"
  # for CAPTCHA challenges
  depends_on "imagemagick" => :optional

  def install
    ENV["TARGET_DIR"] = ENV["DESTDIR"] = "#{lib}/ejabberd/erlang/lib/ejabberd-#{version}"
    ENV["MAN_DIR"] = man
    ENV["SBIN_DIR"] = sbin

    args = ["--prefix=#{prefix}",
            "--bindir=#{prefix}/ebin",
            "--sysconfdir=#{etc}",
            "--localstatedir=#{var}",
            "--enable-all",
           ]

    system "./autogen.sh"
    system "./configure", *args
    system "make"
    system "make", "install"

    (etc/"ejabberd").mkpath
    (var/"lib/ejabberd").mkpath
    (var/"spool/ejabberd").mkpath
  end

  def caveats; <<-EOS.undent
    If you face nodedown problems, concat your machine name to:
      /private/etc/hosts
    after 'localhost'.
    EOS
  end

  plist_options :manual => "#{HOMEBREW_PREFIX}/sbin/ejabberdctl start"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>EnvironmentVariables</key>
      <dict>
        <key>HOME</key>
        <string>#{var}/lib/ejabberd</string>
      </dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_sbin}/ejabberdctl</string>
        <string>start</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>WorkingDirectory</key>
      <string>#{var}/lib/ejabberd</string>
    </dict>
    </plist>
    EOS
  end

  test do
    system "#{sbin}/ejabberdctl", "ping"
  end
end
