class Minio < Formula
  desc "object storage server compatible with Amazon S3"
  homepage "https://github.com/minio/minio"
  url "https://github.com/minio/minio.git",
    :tag => "RELEASE.2016-08-21T02-44-47Z",
    :revision => "975eb319730c8db093b4744bf9e012356d61eef2"
  version "20160821024447"

  bottle do
    cellar :any_skip_relocation
    sha256 "cacc25741e6358a9c0c2bcf366d920397bc19f0496f73af79204a3aa8d1cec36" => :el_capitan
    sha256 "1a3ce21135037e729005d3954cd9e77bba933e321779d67ba5ea1b3e87d6b71a" => :yosemite
    sha256 "b9e6290b23324fef659a1c04740e845bba66f8f8da7af1b9617602238e16e4ef" => :mavericks
  end

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath

    clipath = buildpath/"src/github.com/minio/minio"
    clipath.install Dir["*"]

    cd clipath do
      if build.head?
        system "go", "build", "-o", buildpath/"minio"
      else
        release = `git tag --points-at HEAD`.chomp
        version = release.gsub(/RELEASE\./, "").chomp.gsub(/T(\d+)\-(\d+)\-(\d+)Z/, 'T\1:\2:\3Z')
        commit = `git rev-parse HEAD`.chomp
        proj = "github.com/minio/minio/"

        system "go", "build", "-o", buildpath/"minio", "-ldflags", <<-EOS.undent
            -X #{proj}/cmd.Version=#{version}
            -X #{proj}/cmd.ReleaseTag=#{release}
            -X #{proj}/cmd.CommitID=#{commit}
            EOS
      end
    end

    bin.install buildpath/"minio"
  end

  def post_install
    DATADIR.mkpath = "var/minio".freeze
    CONFIGDIR.mkpath = "etc/minio".freeze
  end

  plist_options :manual => "minio server"

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
        <string>#{opt_bin}/minio</string>
        <string>server</string>
        <string>--config-dir=#{CONFIGDIR}</string>
        <string>--address :9000</string>
        <string>#{DATADIR}</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>WorkingDirectory</key>
      <string>#{DATADIR}</string>
    </dict>
    </plist>
    EOS
  end

  test do
    system "#{bin}/minio", "version"
  end
end
