class SeleniumServerStandalone < Formula
  desc "Browser automation for testing purposes"
  homepage "http://seleniumhq.org/"
  url "https://selenium-release.storage.googleapis.com/3.6/selenium-server-standalone-3.6.0.jar"
  sha256 "e21c972f5a0e58e56ee368ba95e202b2117954aa4eae3a9760f86f542d206387"

  bottle :unneeded

  def install
    libexec.install "selenium-server-standalone-#{version}.jar"
    bin.write_jar_script libexec/"selenium-server-standalone-#{version}.jar", "selenium-server"
  end

  plist_options :manual => "selenium-server -port 4444"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>RunAtLoad</key>
      <true/>
      <key>KeepAlive</key>
      <false/>
      <key>ProgramArguments</key>
      <array>
        <string>/usr/bin/java</string>
        <string>-jar</string>
        <string>#{libexec}/selenium-server-standalone-#{version}.jar</string>
        <string>-port</string>
        <string>4444</string>
      </array>
      <key>ServiceDescription</key>
      <string>Selenium Server</string>
      <key>StandardErrorPath</key>
      <string>#{var}/log/selenium-error.log</string>
      <key>StandardOutPath</key>
      <string>#{var}/log/selenium-output.log</string>
    </dict>
    </plist>
    EOS
  end

  test do
    selenium_version = shell_output("unzip -p #{libexec}/selenium-server-standalone-#{version}.jar META-INF/MANIFEST.MF | sed -nEe '/Selenium-Version:/p'")
    assert_equal "Selenium-Version: #{version}", selenium_version.strip
  end
end
