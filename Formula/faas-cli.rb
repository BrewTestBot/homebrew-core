class FaasCli < Formula
  desc "CLI for templating and/or deploying FaaS functions"
  homepage "http://docs.get-faas.com/"
  url "https://github.com/openfaas/faas-cli.git",
      :tag => "0.4.18c",
      :revision => "fe0b89352e9c078c951a9f100cd4a7daae1ca15c"
  version "0.4.18c"

  bottle do
    cellar :any_skip_relocation
    sha256 "9f7250809e84eba0b367f94271282bc0e524fb801de1f19ed34b22911f2f9702" => :high_sierra
    sha256 "457ad06f7b77f2b36f6e76d0f8dd037e712bcb4183dd761b0c302300f587d184" => :sierra
    sha256 "fd6ee1cd7b10138f480af67a63531773e660a0c4135e6b8b265a6e5b84462812" => :el_capitan
  end

  depends_on "go" => :build

  def install
    ENV["XC_OS"] = "darwin"
    ENV["XC_ARCH"] = MacOS.prefer_64_bit? ? "amd64" : "386"
    ENV["GOPATH"] = buildpath
    (buildpath/"src/github.com/openfaas/faas-cli").install buildpath.children
    cd "src/github.com/openfaas/faas-cli" do
      commit = Utils.popen_read("git rev-list -1 HEAD").chomp
      system "go", "build", "-ldflags", "-s -w -X github.com/openfaas/faas-cli/commands.GitCommit=#{commit}", "-a",
             "-installsuffix", "cgo", "-o", bin/"faas-cli"
      prefix.install_metafiles
    end
  end

  test do
    require "socket"

    server = TCPServer.new("localhost", 0)
    port = server.addr[1]
    pid = fork do
      loop do
        socket = server.accept
        response = "OK"
        socket.print "HTTP/1.1 200 OK\r\n" \
                    "Content-Length: #{response.bytesize}\r\n" \
                    "Connection: close\r\n"
        socket.print "\r\n"
        socket.print response
        socket.close
      end
    end

    (testpath/"test.yml").write <<-EOF.undent
      provider:
        name: faas
        gateway: http://localhost:#{port}
        network: "func_functions"

      functions:
        dummy_function:
          lang: python
          handler: ./dummy_function
          image: dummy_image
    EOF

    expected = <<-EOS.undent
      Deploying: dummy_function.
      Removing old service.
      Deployed.
      URL: http://localhost:#{port}/function/dummy_function

      200 OK
    EOS

    begin
      output = shell_output("#{bin}/faas-cli deploy -yaml test.yml")
      assert_equal expected, output

      commit = Utils.popen_read("git rev-list -1 HEAD").chomp
      output = shell_output("#{bin}/faas-cli version")
      assert_match commit, output.chomp
    ensure
      Process.kill("TERM", pid)
      Process.wait(pid)
    end
  end
end
