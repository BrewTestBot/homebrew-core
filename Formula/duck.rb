class Duck < Formula
  desc "Command-line interface for Cyberduck (a multi-protocol file transfer tool)"
  homepage "https://duck.sh/"
  # check the changelog for the latest stable version: https://cyberduck.io/changelog/
  url "https://dist.duck.sh/duck-src-6.8.2.28974.tar.gz"
  sha256 "f57f7c067bdba4ac00cdee3dd1ea4fe36ee9b5c0301da585459d7acb32f05d18"
  head "https://svn.cyberduck.io/trunk/"

  bottle do
    cellar :any
    sha256 "ebde5b128fc26c61a73ada6fb420c35220794bf1b2114d2eb87180d1c4c1a558" => :sierra
  end

  depends_on "ant" => :build
  depends_on :java => ["1.8+", :build]
  depends_on "maven" => :build
  depends_on :xcode => :build

  def install
    revision = version.to_s.rpartition(".").last
    system "mvn", "-DskipTests", "-Dgit.commitsCount=#{revision}",
                  "--projects", "cli/osx", "--also-make", "verify"
    libexec.install Dir["cli/osx/target/duck.bundle/*"]
    bin.install_symlink "#{libexec}/Contents/MacOS/duck" => "duck"
  end

  test do
    system "#{bin}/duck", "--download", "https://ftp.gnu.org/gnu/wget/wget-1.19.4.tar.gz", testpath/"test"
    assert_equal (testpath/"test").sha256, "93fb96b0f48a20ff5be0d9d9d3c4a986b469cb853131f9d5fe4cc9cecbc8b5b5"
  end
end
