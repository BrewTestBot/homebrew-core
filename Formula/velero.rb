class Velero < Formula
  desc "Backup and migrate Kubernetes applications and their persistent volumes"
  homepage "https://heptio.github.io/velero/"
  url "https://github.com/heptio/velero.git",
    :tag      => "v1.0.0-rc.1",
    :revision => "d05f8e53d8ecbdb939d5d3a3d24da7868619ec3d"

  bottle do
    cellar :any_skip_relocation
    sha256 "fed35c38cdcf0ec5de65a9f42c2a7c3835387a78cd12b55efffd181efd6039ee" => :mojave
    sha256 "26c83897abcf6a3239dfcf986d354cd9290e9c60366b22fe80cfd85ec761487d" => :high_sierra
    sha256 "e11b692b8bdca687c1f3fc564c81ccc5a6c3610b3f39674c24650ec425d24f2c" => :sierra
  end

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    dir = buildpath/"src/github.com/heptio/velero"
    dir.install buildpath.children - [buildpath/".brew_home"]

    cd dir do
      system "go", "build", "-o", bin/"velero", "-installsuffix", "static",
                   "-ldflags",
                   "-X github.com/heptio/velero/pkg/buildinfo.Version=v#{version}",
                   "./cmd/velero"

      # Install bash completion
      output = Utils.popen_read("#{bin}/velero completion bash")
      (bash_completion/"velero").write output

      # Install zsh completion
      output = Utils.popen_read("#{bin}/velero completion zsh")
      (zsh_completion/"_velero").write output

      prefix.install_metafiles
    end
  end

  test do
    output = shell_output("#{bin}/velero 2>&1")
    assert_match "Velero is a tool for managing disaster recovery", output
    assert_match "Version: v#{version}", shell_output("#{bin}/velero version --client-only 2>&1")
    system bin/"velero", "client", "config", "set", "TEST=value"
    assert_match "value", shell_output("#{bin}/velero client config get 2>&1")
  end
end
