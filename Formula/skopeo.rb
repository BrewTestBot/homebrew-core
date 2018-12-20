class Skopeo < Formula
  desc "Work with remote images registries"
  homepage "https://github.com/containers/skopeo"
  url "https://github.com/containers/skopeo/archive/v0.1.33.tar.gz"
  sha256 "04cb5e00805d5203cf4f9eaee22e3f3c0e6f951004b837eea2d7aff0f5897f5a"

  bottle do
    cellar :any
    sha256 "9c164ac9e4f689baeaa548ee7aad5c8504b3630c28561b17dd0a481146681bb9" => :mojave
    sha256 "758598ce8947a1305146b9a3fafa5825efaa3d5f3e4509955f0df0768c087510" => :high_sierra
    sha256 "e61ddf1b046bd8db6ca82dd5b4aff0807ea297504fd3d54118feb7a70eaa3532" => :sierra
  end

  depends_on "go" => :build
  depends_on "gpgme"

  def install
    ENV["GOPATH"] = buildpath
    (buildpath/"src/github.com/containers/skopeo").install buildpath.children
    cd "src/github.com/containers/skopeo" do
      system "make", "binary-local"
      bin.install "skopeo"
      prefix.install_metafiles
    end
  end

  test do
    cmd = "#{bin}/skopeo --override-os linux inspect docker://busybox"
    output = shell_output(cmd)
    assert_match "docker.io/library/busybox", output
  end
end
