class Geph2 < Formula
  desc "Modular Internet censorship circumvention system"
  homepage "https://geph.io"
  url "https://github.com/geph-official/geph2/archive/v0.20.2.tar.gz"
  sha256 "fe5bef5ed04ab6f2e254e7e142ce93d57f5f1c157651db2c29aaf3cf13abf647"

  bottle do
    cellar :any_skip_relocation
    sha256 "d290f4fc037ecd649dcec532c0f27b8bab89cc461c045c3ec577f7c3fd32b7ad" => :catalina
    sha256 "d290f4fc037ecd649dcec532c0f27b8bab89cc461c045c3ec577f7c3fd32b7ad" => :mojave
    sha256 "d290f4fc037ecd649dcec532c0f27b8bab89cc461c045c3ec577f7c3fd32b7ad" => :high_sierra
  end

  depends_on "go" => :build

  def install
    bin_path = buildpath/"src/github.com/geph-official/geph2"
    bin_path.install Dir["*"]
    cd bin_path/"cmd/geph-client" do
      ENV["CGO_ENABLED"] = "0"
      system "go", "build", "-o",
       bin/"geph-client", "-v", "-trimpath"
    end
  end

  test do
    assert_match "-username", shell_output("#{bin}/geph-client -h 2>&1", 2)
  end
end
