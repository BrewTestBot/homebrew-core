require "open3"

class Arangodb < Formula
  desc "The Multi-Model NoSQL Database"
  homepage "https://www.arangodb.com/"
  url "https://download.arangodb.com/Source/ArangoDB-3.4.2-1.tar.gz"
  sha256 "ecd73853222d01439eba4fabbcca33d21c43cc112dc98b0a8f89aa69d5b352a0"
  head "https://github.com/arangodb/arangodb.git", :branch => "unstable"

  bottle do
    sha256 "f6d5a7ab21414ee300fd84403d39637ee671ca8418a6b145e9719ba766f69ff9" => :mojave
    sha256 "f8856d51689fdae760d313107b3d577b4350157f041ea8ac8234362874c1af47" => :high_sierra
    sha256 "5f221d04ee48844ec9de104d7a750b93da922134c71d3553e5b0fbbe31c5a3f6" => :sierra
  end

  depends_on "cmake" => :build
  depends_on "go" => :build
  depends_on :macos => :yosemite
  depends_on "openssl"

  # see https://gcc.gnu.org/bugzilla/show_bug.cgi?id=87665
  fails_with :gcc do
    build 730
    cause "Generates incorrect code"
  end

  fails_with :gcc do
    build 820
    cause "Generates incorrect code"
  end

  # the ArangoStarter is in a separate github repository;
  # it is used to easily start single server and clusters
  # with a unified CLI
  resource "starter" do
    url "https://github.com/arangodb-helper/arangodb/archive/0.14.0.tar.gz"
    sha256 "43f9c6ecd492541c4616df523513898ad1512bec7baa245852ee4c401b786f2c"
  end

  def install
    ENV.cxx11

    resource("starter").stage do
      ENV.append "GOPATH", Dir.pwd + "/.gobuild"
      system "make", "deps"
      system "go", "build", "-ldflags", "-X main.projectVersion=0.14.0 -X main.projectBuild=43f9c6ecd492541c4616df523513898ad1512bec7baa245852ee4c401b786f2c",
                            "-o", "arangodb",
                            "github.com/arangodb-helper/arangodb"
      bin.install "arangodb"
    end

    mkdir "build" do
      args = std_cmake_args + %W[
        -DHOMEBREW=ON
        -DUSE_OPTIMIZE_FOR_ARCHITECTURE=OFF
        -DASM_OPTIMIZATIONS=OFF
        -DCMAKE_INSTALL_DATADIR=#{share}
        -DCMAKE_INSTALL_DATAROOTDIR=#{share}
        -DCMAKE_INSTALL_SYSCONFDIR=#{etc}
        -DCMAKE_INSTALL_LOCALSTATEDIR=#{var}
      ]

      if ENV.compiler == "gcc-6"
        ENV.append "V8_CXXFLAGS", "-O3 -g -fno-delete-null-pointer-checks"
      end

      system "cmake", "..", *args
      system "make", "install"

      %w[arangod arango-dfdb arangosh foxx-manager].each do |f|
        inreplace etc/"arangodb3/#{f}.conf", pkgshare, opt_pkgshare
      end
    end
  end

  def post_install
    (var/"lib/arangodb3").mkpath
    (var/"log/arangodb3").mkpath
  end

  def caveats
    s = <<~EOS
      An empty password has been set. Please change it by executing
        #{opt_sbin}/arango-secure-installation
    EOS

    s
  end

  plist_options :manual => "#{HOMEBREW_PREFIX}/opt/arangodb/sbin/arangod"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>KeepAlive</key>
        <true/>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>Program</key>
        <string>#{opt_sbin}/arangod</string>
        <key>RunAtLoad</key>
        <true/>
      </dict>
    </plist>
  EOS
  end

  test do
    require "pty"

    testcase = "require('@arangodb').print('it works!')"
    output = shell_output("#{bin}/arangosh --server.password \"\" --javascript.execute-string \"#{testcase}\"")
    assert_equal "it works!", output.chomp

    ohai "#{bin}/arangodb --starter.instance-up-timeout 1m --starter.mode single"
    PTY.spawn("#{bin}/arangodb", "--starter.instance-up-timeout", "1m", "--starter.mode", "single") do |r, _, pid|
      begin
        loop do
          available = IO.select([r], [], [], 60)
          assert_not_equal available, nil

          line = r.readline.strip
          ohai line

          break if line.include?("Your single server can now be accessed")
        end
      ensure
        Process.kill "SIGINT", pid
        ohai "shuting down #{pid}"
      end
    end
  end
end
