class Modsman < Formula
  desc "Minecraft mod manager for the command-line"
  homepage "https://gitlab.com/sargunv-mc-mods/modsman"
  url "https://gitlab.com/sargunv-mc-mods/modsman.git",
      :tag      => "0.20.1"
  sha256 "09834f6b34014652e6dd46a4e3c0ecb9d353002d44053854d05faffd3efc022b"

  depends_on :java => "1.8+"

  def install
    system "./gradlew", ":modsman-cli:installDist"
    libexec.install Dir["modsman-cli/build/install/modsman-cli/*"]
    rm_f Dir["#{libexec}/bin/*.bat"]
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    # TODO: replace this with a proper test
    system "#{bin}/modsman-cli", "--version"
  end
end
