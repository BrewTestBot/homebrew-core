class Couchdb < Formula
  desc "Document database server"
  homepage "https://couchdb.apache.org/"
  url "https://www.apache.org/dyn/closer.cgi?path=/couchdb/source/1.7.2/apache-couchdb-1.7.2.tar.gz"
  mirror "https://archive.apache.org/dist/couchdb/source/1.7.2/apache-couchdb-1.7.2.tar.gz"
  sha256 "7b7c0db046ded544a587a8935d495610dd10f01a9cae3cd42cf88c5ae40bc431"
  revision 2

  bottle do
    sha256 "db687c920dfc1d79921048706f9277eabbcad57037ab19883e12ed816f9c371d" => :catalina
    sha256 "79c256711974f24cbbc7cdb9d75c1ad88d76848c6eb0dc651fca5002fc130add" => :mojave
    sha256 "75f0629a87c9d83e787f67ffafc6dc84968e9d7af12b3bd2499f31bc1920255f" => :high_sierra
  end

  head do
    url "https://github.com/apache/couchdb.git"

    depends_on "autoconf" => :build
    depends_on "autoconf-archive" => :build
    depends_on "automake" => :build
    depends_on "help2man" => :build
    depends_on "libtool" => :build
    depends_on "pkg-config" => :build
  end

  depends_on "erlang@19"
  depends_on "icu4c"
  depends_on "spidermonkey"

  # Allow overwriting old configuration with new symlinks.
  link_overwrite "etc/couchdb/default.ini"
  link_overwrite "etc/couchdb/local.ini"
  link_overwrite "etc/logrotate.d/couchdb"

  def install
    # CouchDB >=1.3.0 supports vendor names and versioning
    # in the welcome message
    inreplace "etc/couchdb/default.ini.tpl.in" do |s|
      s.gsub! "%package_author_name%", "Homebrew"
      s.gsub! "%version%", pkg_version
    end

    unless build.stable?
      # workaround for the auto-generation of THANKS file which assumes
      # a developer build environment incl access to git sha
      touch "THANKS"
      system "./bootstrap"
    end

    system "./configure", "--prefix=#{prefix}",
                          "--localstatedir=#{var}",
                          "--sysconfdir=#{prefix}/etc",
                          "--disable-init",
                          "--with-erlang=#{Formula["erlang@19"].opt_lib}/erlang/usr/include",
                          "--with-js-include=#{HOMEBREW_PREFIX}/include/js",
                          "--with-js-lib=#{HOMEBREW_PREFIX}/lib"
    system "make"
    system "make", "install"

    # Use our plist instead to avoid faffing with a new system user.
    (prefix/"Library/LaunchDaemons/org.apache.couchdb.plist").delete
    (lib/"couchdb/bin/couchjs").chmod 0755
  end

  def post_install
    (var/"lib/couchdb").mkpath
    (var/"log/couchdb").mkpath
    (var/"run/couchdb").mkpath
  end

  plist_options :manual => "couchdb"

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
        <string>#{opt_bin}/couchdb</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
    </dict>
    </plist>
  EOS
  end

  test do
    # ensure couchdb embedded spidermonkey vm works
    system "#{bin}/couchjs", "-h"

    (testpath/"var/lib/couchdb").mkpath
    (testpath/"var/log/couchdb").mkpath
    (testpath/"var/run/couchdb").mkpath
    cp_r prefix/"etc/couchdb", testpath
    inreplace "#{testpath}/couchdb/default.ini", "/usr/local/var", testpath/"var"

    pid = fork do
      exec "#{bin}/couchdb -A #{testpath}/couchdb"
    end
    sleep 2

    begin
      assert_match "Homebrew", shell_output("curl -# localhost:5984")
    ensure
      Process.kill("SIGINT", pid)
      Process.wait(pid)
    end
  end
end
