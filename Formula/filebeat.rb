class Filebeat < Formula
  desc "File harvester to ship log files to Elasticsearch or Logstash"
  homepage "https://www.elastic.co/products/beats/filebeat"
  url "https://github.com/elastic/beats/archive/v6.2.2.tar.gz"
  sha256 "0866c3e26fcbd55f191e746b3bf925b450badd13fb72ea9f712481559932c878"
  head "https://github.com/elastic/beats.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "452dfc74f6fb8bc0db672a9f0aeac875f133f74428460ff5e90c83e9b784bd74" => :high_sierra
    sha256 "18f6a3dcee99bb27938b0ceff3ede0f1a11cbcb0c123fdb229142caf983b18ea" => :sierra
    sha256 "efa963c66bfd69ee503b9f0011b5e733a93b7fcac7e1971ac18ee4fdd3b33894" => :el_capitan
  end

  depends_on "go" => :build

  resource "virtualenv" do
    url "https://files.pythonhosted.org/packages/d4/0c/9840c08189e030873387a73b90ada981885010dd9aea134d6de30cd24cb8/virtualenv-15.1.0.tar.gz"
    sha256 "02f8102c2436bb03b3ee6dede1919d1dac8a427541652e5ec95171ec8adbc93a"
  end

  def install
    ENV["GOPATH"] = buildpath
    (buildpath/"src/github.com/elastic/beats").install Dir["{*,.git,.gitignore}"]

    ENV.prepend_create_path "PYTHONPATH", buildpath/"vendor/lib/python2.7/site-packages"

    resource("virtualenv").stage do
      system "python", *Language::Python.setup_install_args(buildpath/"vendor")
    end

    ENV.prepend_path "PATH", buildpath/"vendor/bin"

    cd "src/github.com/elastic/beats/filebeat" do
      system "make"
      # prevent downloading binary wheels during python setup
      system "make", "PIP_INSTALL_COMMANDS=--no-binary :all", "python-env"
      system "make", "DEV_OS=darwin", "update"
      system "make", "modules"
      libexec.install "filebeat"
      (prefix/"module").install Dir["_meta/module.generated/*"]
      (etc/"filebeat").install Dir["filebeat.*", "fields.yml"]
    end

    prefix.install_metafiles buildpath/"src/github.com/elastic/beats"

    (bin/"filebeat").write <<~EOS
      #!/bin/sh
      exec #{libexec}/filebeat -path.config #{etc}/filebeat -path.home #{prefix} -path.logs #{var}/log/filebeat -path.data #{var}/filebeat $@
    EOS
  end

  plist_options :manual => "filebeat"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN"
    "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>Program</key>
        <string>#{opt_bin}/filebeat</string>
        <key>RunAtLoad</key>
        <true/>
      </dict>
    </plist>
  EOS
  end

  test do
    log_file = testpath/"test.log"
    touch log_file

    (testpath/"filebeat.yml").write <<~EOS
      filebeat:
        prospectors:
          -
            paths:
              - #{log_file}
            scan_frequency: 0.1s
      output:
        file:
          path: #{testpath}
    EOS

    (testpath/"log").mkpath
    (testpath/"data").mkpath

    filebeat_pid = fork { exec "#{bin}/filebeat -c #{testpath}/filebeat.yml -path.config #{testpath}/filebeat -path.home=#{testpath} -path.logs #{testpath}/log -path.data #{testpath}" }
    begin
      sleep 1
      log_file.append_lines "foo bar baz"
      sleep 5

      assert_predicate testpath/"filebeat", :exist?
    ensure
      Process.kill("TERM", filebeat_pid)
    end
  end
end
