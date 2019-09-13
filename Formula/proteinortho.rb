class Proteinortho < Formula
  desc "Detecting orthologous genes within different species"
  homepage "https://gitlab.com/paulklemm_PHD/proteinortho"
  url "https://gitlab.com/paulklemm_PHD/proteinortho/-/archive/v6.0.7/proteinortho-v6.0.7.tar.gz"
  sha256 "a9c5888ef12234e1d228e4ae1ef591e52b0be112d72022e047f2bcbaf1e18a21"

  bottle do
    cellar :any
    sha256 "5b3c2df4140fa1e0093527988d47b95b5d1cf4e13b65507abe05a0260491eb47" => :mojave
    sha256 "d5016e0ec7744ec62a1194df1c1ec917cf385b113fbda882ce5ba4bd66deef28" => :high_sierra
    sha256 "c0e455ca6c7d95df893b4a6bc3195b74dcc02511c179acd879ea85eaab067bc6" => :sierra
  end

  depends_on "diamond"
  depends_on "openblas"

  def install
    bin.mkpath
    system "make", "install", "PREFIX=#{bin}"
    doc.install "manual.html"
  end

  test do
    system "#{bin}/proteinortho", "-test"
    system "#{bin}/proteinortho_clustering", "-test"
  end
end
