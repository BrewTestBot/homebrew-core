class Mkvalidator < Formula
  desc "Tool to verify Matroska and WebM files for spec conformance"
  homepage "https://www.matroska.org/downloads/mkvalidator.html"
  url "https://downloads.sourceforge.net/project/matroska/mkvalidator/mkvalidator-0.5.2.tar.bz2"
  sha256 "2e2a91062f6bf6034e8049646897095b5fc7a1639787d5fe0fcef1f1215d873b"

  bottle do
    cellar :any_skip_relocation
    rebuild 1
    sha256 "5722cbd433c58814fc7508ca19161c0de3f5fd8102e94cded96d09e9cfc771bc" => :high_sierra
    sha256 "49fa0aa455c2787b47cdad885529291a1471e733e49918b2f8f27359022f5a80" => :sierra
    sha256 "fe23d687f75ca9d28b75c9886b0eca1830861f2d47d5e03eea8d9cae0f2f0441" => :el_capitan
    sha256 "e10253ba9942b7d4d92a66efd55fb04671af4edd73bddeed302f5373591d244f" => :yosemite
    sha256 "8a6c2abe6c63609e04f4855f25b336418d6ae9f10f95061c40efd811372afb0f" => :mavericks
  end

  resource "tests" do
    url "https://github.com/dunn/garbage/raw/c0e682836e5237eef42a000e7d00dcd4b6dcebdb/test.mka"
    sha256 "6d7cc62177ec3f88c908614ad54b86dde469dbd2b348761f6512d6fc655ec90c"
  end

  def install
    ENV.deparallelize # Otherwise there are races

    # Reported 2 Nov 2017 https://github.com/Matroska-Org/foundation-source/issues/31
    inreplace "configure", "\r", "\n"

    system "./configure"
    system "make", "-C", "mkvalidator"
    bindir = `corec/tools/coremake/system_output.sh`.chomp
    bin.install "release/#{bindir}/mkvalidator"
  end

  test do
    resource("tests").stage do
      system bin/"mkvalidator", "test.mka"
    end
  end
end
