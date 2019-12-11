class Fastlane < Formula
  desc "Easiest way to build and release mobile apps"
  homepage "https://fastlane.tools"
  url "https://github.com/fastlane/fastlane/archive/2.137.0.tar.gz"
  sha256 "ff3813d75bbced1030b5d7e3e714e75f358788f74d951be796515e8ec4e7ec79"
  head "https://github.com/fastlane/fastlane.git"

  depends_on "ruby@2.5"

  def install
    ENV["GEM_HOME"] = libexec
    ENV["GEM_PATH"] = libexec

    system "gem", "build", "fastlane.gemspec"
    system "gem", "install", "fastlane-#{version}.gem", "--no-document"

    (bin/"fastlane").write <<~EOS
      #!/bin/bash
      export PATH="#{Formula["ruby@2.5"].opt_bin}:$PATH}"
      GEM_HOME="#{libexec}" GEM_PATH="#{libexec}" \\
        exec "#{libexec}/bin/fastlane" "$@"
    EOS
    chmod "+x", bin/"fastlane"
  end

  test do
    version_output = shell_output("#{bin}/fastlane --version")
    assert_true version_output.include?("fastlane #{version}")
    assert_true version_output.include?("#{prefix}/libexec/gems/fastlane-#{version}/bin/fastlane")

    actions_output = shell_output("#{bin}/fastlane actions")
    actions_output.include?("gym")
    actions_output.include?("pilot")
    actions_output.include?("screengrab")
    actions_output.include?("supply")
  end
end
