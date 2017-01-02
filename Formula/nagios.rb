class Nagios < Formula
  desc "Network monitoring and management system"
  homepage "https://www.nagios.org/"
  url "https://downloads.sourceforge.net/project/nagios/nagios-4.x/nagios-4.2.4/nagios-4.2.4.tar.gz"
  sha256 "b0055c475683ce50d77b1536ff0cec9abf89139adecf771601fa021ef9a20b70"

  bottle do
    cellar :any
    sha256 "1b7ef621545f9513777feca6fae80eb74e3b4ff89741fb5e535564c5d874295d" => :sierra
    sha256 "36fd9a8eda1286902fefea97a76e508e27c6cd7fd6cc2156558411f6b3f32709" => :el_capitan
    sha256 "d577fda33880b29093628affbf7e71d9e1e37220f84b6c83cc7dbb05875fa86a" => :yosemite
    sha256 "e5a625fae90701cbbfa97fa872c8a694d1365f04d970822e3bc8d81aa37ca667" => :mavericks
  end

  depends_on "gd"
  depends_on "nagios-plugins"
  depends_on "libpng"

  def nagios_sbin
    prefix/"cgi-bin"
  end

  def nagios_etc
    etc/"nagios"
  end

  def nagios_var
    var/"lib/nagios"
  end

  def htdocs
    pkgshare/"htdocs"
  end

  def user
    Utils.popen_read("id -un").chomp
  end

  def group
    Utils.popen_read("id -gn").chomp
  end

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--sbindir=#{nagios_sbin}",
                          "--sysconfdir=#{nagios_etc}",
                          "--localstatedir=#{nagios_var}",
                          "--datadir=#{htdocs}",
                          "--libexecdir=#{HOMEBREW_PREFIX}/sbin", # Plugin dir
                          "--with-cgiurl=/nagios/cgi-bin",
                          "--with-htmurl=/nagios",
                          "--with-nagios-user=#{user}",
                          "--with-nagios-group='#{group}'",
                          "--with-command-user=#{user}",
                          "--with-command-group=_www",
                          "--with-httpd-conf=#{share}"
    system "make", "all"
    system "make", "install"

    # Install config
    system "make", "install-config"
    system "make", "install-webconf"
  end

  def postinstall
    (var/"lib/nagios/rw").mkpath

    config = etc/"nagios/nagios.cfg"
    return unless File.exist?(config)
    return if File.read(config).include?(ENV["USER"])
    inreplace config, "brew", ENV["USER"]
  end

  def caveats; <<-EOS.undent
    First we need to create a command dir using superhuman powers:

      mkdir -p #{nagios_var}/rw
      sudo chgrp _www #{nagios_var}/rw
      sudo chmod 2775 #{nagios_var}/rw

    Then install the Nagios web frontend into Apple's build-in Apache:

      1) Turn on Personal Web Sharing.

      2) Load the cgi and php modules by patching /etc/apache2/httpd.conf:

        -#LoadModule php5_module        libexec/apache2/libphp5.so
        +LoadModule php5_module        libexec/apache2/libphp5.so

        -#LoadModule cgi_module libexec/apache2/mod_cgi.so
        +LoadModule cgi_module libexec/apache2/mod_cgi.so

      3) Symlink the sample config and create your web account:

        sudo ln -sf #{share}/nagios.conf /etc/apache2/other/
        htpasswd -cs #{nagios_etc}/htpasswd.users nagiosadmin
        sudo apachectl restart

    Log in with your web account (and don't forget to RTFM :-)

      open http://localhost/nagios

    EOS
  end

  plist_options :startup => true, :manual => "nagios #{HOMEBREW_PREFIX}/etc/nagios/nagios.cfg"

  def plist; <<-EOS.undent
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
        <string>#{opt_bin}/nagios</string>
        <string>#{nagios_etc}/nagios.cfg</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>StandardErrorPath</key>
      <string>/dev/null</string>
      <key>StandardOutPath</key>
      <string>/dev/null</string>
    </dict>
    </plist>
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/nagios --version")
  end
end
