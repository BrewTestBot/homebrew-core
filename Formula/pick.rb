class Pick < Formula
  desc "Utility to choose one option from a set of choices"
  homepage "https://github.com/calleerlandsson/pick"
  url "https://github.com/calleerlandsson/pick/releases/download/v1.7.0/pick-1.7.0.tar.gz"
  sha256 "950531c56edc4be375fe4e89291caa807322b298143043e2e2963de34e96de15"

  bottle do
    cellar :any_skip_relocation
    sha256 "515cd6fc898dc04351fcb9308a63abd677e5c5ffa775db1e56e03a70b8cfd2d3" => :sierra
    sha256 "ca391b778eb35ac2e0f8527f01f95ae3f9cc3dedc4024fe469f38158224d10dc" => :el_capitan
    sha256 "a93289a3a7f8ef00e4ee0dc96e5add2baa4b237a4ba2683cbde45943fc4b4c5e" => :yosemite
  end

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "check"
    system "make", "install"
  end

  test do
    system "#{bin}/pick", "-v"
  end
end
