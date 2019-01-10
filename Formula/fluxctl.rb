class Fluxctl < Formula
  desc "Command-line tool to access Weave Flux, the Kubernetes GitOps operator"
  homepage "https://github.com/weaveworks/flux"
  url "https://github.com/weaveworks/flux.git",
      :tag      => "1.9.0",
      :revision => "40cd663e74561e14b1dc5a65bf7ed2fff6cf4792"

  bottle do
    cellar :any_skip_relocation
    sha256 "dd6178e92ecb3fe13f70bcbb221a5887e727db89c1a814c055f5805f49988e27" => :mojave
    sha256 "17af512cda7621774b08f96eb91a5b39105f687a77a52d1241e64c31abf657be" => :high_sierra
    sha256 "69d8b8ff7866037e750fb392380f68da843c1a8e609ccf50a81371e4bf5c792b" => :sierra
  end

  depends_on "dep" => :build
  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    dir = buildpath/"src/github.com/weaveworks/flux"
    dir.install buildpath.children - [buildpath/".brew_home"]

    cd dir do
      system "dep", "ensure", "-vendor-only"
      system "make", "release-bins"
      bin.install "build/fluxctl_darwin_amd64" => "fluxctl"
      prefix.install_metafiles
    end
  end

  test do
    run_output = shell_output("#{bin}/fluxctl 2>&1")
    assert_match "fluxctl helps you deploy your code.", run_output

    version_output = shell_output("#{bin}/fluxctl version 2>&1")
    assert_match version.to_s, version_output

    # As we can't bring up a Kubernetes cluster in this test, we simply
    # run "fluxctl sync" and check that it 1) errors out, and 2) complains
    # about a missing .kube/config file.
    require "pty"
    require "timeout"
    r, _w, pid = PTY.spawn("#{bin}/fluxctl sync", :err=>:out)
    begin
      Timeout.timeout(5) do
        assert r.gets.chomp =~ %r{Error: stat .*\/.kube\/config: no such file or directory}
        Process.wait pid
        assert_equal 1, $CHILD_STATUS.exitstatus
      end
    rescue Timeout::Error
      puts "process not finished in time, killing it"
      Process.kill("TERM", pid)
    end
  end
end
