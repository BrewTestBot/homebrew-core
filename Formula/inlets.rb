class Inlets < Formula
  desc "Expose your local endpoints to the Internet"
  homepage "https://github.com/alexellis/inlets"
  url "https://github.com/alexellis/inlets.git",
      :tag      => "2.1.0",
      :revision => "c23f6993892a1b4e398e8acf61e3dc7bfcb7c6ed"

  bottle do
    cellar :any_skip_relocation
    sha256 "ae043173388755cfe95c41b8985262aa3306204be95d75e2e06ffadbf667a96d" => :mojave
    sha256 "94b7edab9f0b79680cb8bd79376043657beb88fd8029d109807210fda87a9012" => :high_sierra
    sha256 "8603c3d0319a55621d96398cd99a7d285aa0355f0c1764f95cfd342c2bdf1d94" => :sierra
  end

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    (buildpath/"src/github.com/alexellis/inlets").install buildpath.children
    cd "src/github.com/alexellis/inlets" do
      commit = Utils.popen_read("git", "rev-parse", "HEAD").chomp
      system "go", "build", "-ldflags",
             "-s -w -X main.GitCommit=#{commit} -X main.Version=#{version}",
             "-a",
             "-installsuffix", "cgo", "-o", bin/"inlets"
      prefix.install_metafiles
    end
  end

  def cleanup(name, pid)
    puts "Tearing down #{name} on PID #{pid}"
    Process.kill("TERM", pid)
    Process.wait(pid)
  end

  MOCK_RESPONSE = "INLETS OK".freeze

  test do
    upstream_server = TCPServer.new(0)
    upstream_port = upstream_server.addr[1]
    remote_server = TCPServer.new(0)
    remote_port = remote_server.addr[1]
    upstream_server.close
    remote_server.close

    puts "Starting mock server on: localhost:#{upstream_port}"

    (testpath/"mock_upstream_server.rb").write <<~EOS
      require 'socket'

      server = TCPServer.new('localhost', #{upstream_port})

      loop do
        socket = server.accept
        request = socket.gets
        STDERR.puts request

        response = "OK\\n"
        shutdown = false

        if request.include? "inlets-test"
          response = "#{MOCK_RESPONSE}\\n"
          shutdown = true
        end

        socket.print "HTTP/1.1 200 OK\\r\\n" +
                    "Content-Type: text/plain\\r\\n" +
                    "Content-Length: \#\{response.bytesize\}\\r\\n" +
                    "Connection: close\\r\\n"

        socket.print "\\r\\n"
        socket.print response
        socket.close

        if shutdown
          puts "Exiting test server"
          exit 0
        end
      end
    EOS

    mock_upstream_server_pid = fork do
      exec "ruby mock_upstream_server.rb"
    end

    begin
      require "uri"
      require "net/http"

      stable_resource = stable.instance_variable_get(:@resource)
      commit = stable_resource.instance_variable_get(:@specs)[:revision]

      # Basic --version test
      inlets_version = shell_output("#{bin}/inlets --version")
      assert_match /\s#{commit}$/, inlets_version
      assert_match /\s#{version}$/, inlets_version

      # Client/Server e2e test
      # This test involves establishing a client-server inlets tunnel on the
      # remote_port, running a mock server on the upstream_port and then
      # testing that we can hit the mock server upstream_port via the tunnel remote_port
      puts "Waiting for mock server"
      sleep 3
      server_pid = fork do
        puts "Starting inlets server with port #{remote_port}"
        exec "#{bin}/inlets server --port #{remote_port}"
      end

      client_pid = fork do
        puts "Starting inlets client with remote localhost:#{remote_port}, upstream localhost:#{upstream_port}"
        exec "#{bin}/inlets client --remote localhost:#{remote_port} --upstream localhost:#{upstream_port}"
      end

      puts "Waiting for inlets websocket tunnel"
      sleep 3

      uri = URI("http://localhost:#{remote_port}/inlets-test")
      puts "Querying upstream endpoint via inlets remote: #{uri}"
      response = Net::HTTP.get_response(uri)
      assert_match MOCK_RESPONSE, response.body
      assert_equal response.code, "200"
    ensure
      cleanup("Mock Server", mock_upstream_server_pid)
      cleanup("Inlets Server", server_pid)
      cleanup("Inlets Client", client_pid)
    end
  end
end
