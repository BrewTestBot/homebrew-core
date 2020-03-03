class Volta < Formula
  desc "JavaScript toolchain manager for reproducible environments"
  homepage "https://volta.sh"
  url "https://github.com/volta-cli/volta.git",
    :revision => "10a9bee148d2a833069d6cc27aea56af3092dc6e",
    :tag      => "v0.7.2"

  depends_on "rust" => :build

  def install
    ENV["VOLTA_HOME"] = prefix.to_s
    system "./dev/unix/volta-install.sh", "--release", "--skip-setup"
  end

  test do
    system "#{bin}/volta", "install", "node@12.16.1"
    node = shell_output("#{bin}/volta which node").chomp
    assert_match "12.16.1", shell_output("#{node} --version")
  end
end
