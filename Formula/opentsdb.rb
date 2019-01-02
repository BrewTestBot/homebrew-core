class Opentsdb < Formula
  desc "Scalable, distributed Time Series Database"
  homepage "http://opentsdb.net/"
  url "https://github.com/OpenTSDB/opentsdb/releases/download/v2.4.0/opentsdb-2.4.0.tar.gz"
  sha256 "a2d6a34369612b3f91bf81bfab24ec573ab4118127dc1c0f0ed6fc57318d102c"

  bottle do
    cellar :any_skip_relocation
    sha256 "873c292be1f409d75f94df294b3485b31f92df119d3d20fcd5b243c5a884e608" => :mojave
    sha256 "0fc3c05e00fcae35985cd3726b08049deb3ba9c4a7bb5a023fc4bbe7ca40d27a" => :high_sierra
    sha256 "748a1b8a84ea3674cf4dffc9d6658c120579036c23506884c2e2e2636927491d" => :sierra
  end

  depends_on "hbase"
  depends_on :java => "1.8"
  depends_on "lzo"
  depends_on "gnuplot" => :optional

  def install
    system "./configure",
           "--disable-silent-rules",
           "--prefix=#{prefix}",
           "--mandir=#{man}",
           "--sysconfdir=#{etc}",
           "--localstatedir=#{var}/opentsdb"
    system "make"
    bin.mkpath
    (pkgshare/"static/gwt/opentsdb/images/ie6").mkpath
    system "make", "install"

    env = {
      :HBASE_HOME  => Formula["hbase"].opt_libexec,
      :COMPRESSION => "LZO",
    }
    env = Language::Java.java_home_env("1.8").merge(env)
    create_table = pkgshare/"tools/create_table_with_env.sh"
    create_table.write_env_script pkgshare/"tools/create_table.sh", env
    create_table.chmod 0755

    inreplace pkgshare/"etc/opentsdb/opentsdb.conf", "/usr/share", "#{HOMEBREW_PREFIX}/share"
    etc.install pkgshare/"etc/opentsdb"
    (pkgshare/"plugins/.keep").write ""

    (bin/"start-tsdb.sh").write <<~EOS
      #!/bin/sh
      exec "#{opt_bin}/tsdb" tsd \\
        --config="#{etc}/opentsdb/opentsdb.conf" \\
        --staticroot="#{opt_pkgshare}/static/" \\
        --cachedir="#{var}/cache/opentsdb" \\
        --port=4242 \\
        --zkquorum=localhost:2181 \\
        --zkbasedir=/hbase \\
        --auto-metric \\
        "$@"
    EOS
    (bin/"start-tsdb.sh").chmod 0755

    libexec.mkpath
    bin.env_script_all_files(libexec, env)
  end

  def post_install
    (var/"cache/opentsdb").mkpath
    system "#{Formula["hbase"].opt_bin}/start-hbase.sh"
    begin
      sleep 2
      system "#{pkgshare}/tools/create_table_with_env.sh"
    ensure
      system "#{Formula["hbase"].opt_bin}/stop-hbase.sh"
    end
  end

  plist_options :manual => "#{HOMEBREW_PREFIX}/opt/opentsdb/bin/start-tsdb.sh"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>KeepAlive</key>
      <dict>
        <key>OtherJobEnabled</key>
        <dict>
          <key>#{Formula["hbase"].plist_name}</key>
          <true/>
        </dict>
      </dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_bin}/start-tsdb.sh</string>
      </array>
      <key>WorkingDirectory</key>
      <string>#{HOMEBREW_PREFIX}</string>
      <key>StandardOutPath</key>
      <string>#{var}/opentsdb/opentsdb.log</string>
      <key>StandardErrorPath</key>
      <string>#{var}/opentsdb/opentsdb.err</string>
    </dict>
    </plist>
  EOS
  end

  test do
    cp_r (Formula["hbase"].opt_libexec/"conf"), testpath
    inreplace (testpath/"conf/hbase-site.xml") do |s|
      s.gsub! /(hbase.rootdir.*)\n.*/, "\\1\n<value>file://#{testpath}/hbase</value>"
      s.gsub! /(hbase.zookeeper.property.dataDir.*)\n.*/, "\\1\n<value>#{testpath}/zookeeper</value>"
    end

    ENV["HBASE_LOG_DIR"]  = testpath/"logs"
    ENV["HBASE_CONF_DIR"] = testpath/"conf"
    ENV["HBASE_PID_DIR"]  = testpath/"pid"

    system "#{Formula["hbase"].opt_bin}/start-hbase.sh"
    begin
      sleep 2

      system "#{pkgshare}/tools/create_table_with_env.sh"

      tsdb_err = "#{testpath}/tsdb.err"
      tsdb_out = "#{testpath}/tsdb.out"
      tsdb_daemon_pid = fork do
        $stderr.reopen(tsdb_err, "w")
        $stdout.reopen(tsdb_out, "w")
        exec("#{bin}/start-tsdb.sh")
      end
      sleep 15

      begin
        pipe_output("nc localhost 4242 2>&1", "put homebrew.install.test 1356998400 42.5 host=webserver01 cpu=0\n")

        system "#{bin}/tsdb", "query", "1356998000", "1356999000", "sum", "homebrew.install.test", "host=webserver01", "cpu=0"
      ensure
        Process.kill(9, tsdb_daemon_pid)
      end
    ensure
      system "#{Formula["hbase"].opt_bin}/stop-hbase.sh"
    end
  end
end
