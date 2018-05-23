class Bitwarden < Formula
  desc "Secure and free password manager for all of your devices"
  homepage "https://bitwarden.com/"
  url "https://github.com/bitwarden/cli/releases/download/v1.0.0/bw-macos-1.0.0.zip"
  sha256 "4ed81213fe796025c171243ef9c6e66a95a40d9650e87fc86c7e401769cc63d8"

  bottle do
    cellar :any_skip_relocation
    sha256 "4792d95435843bbbe7d8de4fbb34ee088d284e8d03045daddd372dbbbd6aa02d" => :high_sierra
    sha256 "4792d95435843bbbe7d8de4fbb34ee088d284e8d03045daddd372dbbbd6aa02d" => :sierra
    sha256 "4792d95435843bbbe7d8de4fbb34ee088d284e8d03045daddd372dbbbd6aa02d" => :el_capitan
  end

  def install
    libexec.install Dir["*"]
    chmod(0755, "#{libexec}/bw")
    bin.install_symlink("#{libexec}/bw")
  end

  test do
    assert_equal "1.0.0\n", shell_output("#{bin}/bw -v")
  end
end
