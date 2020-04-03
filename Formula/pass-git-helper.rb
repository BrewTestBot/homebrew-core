class PassGitHelper < Formula
  include Language::Python::Virtualenv

  desc "Git credential helper interfacing with pass"
  homepage "https://github.com/languitar/pass-git-helper"
  url "https://github.com/languitar/pass-git-helper/archive/v1.1.0.tar.gz"
  sha256 "85c9e2f1f544227da9129503d91ce5d502be127c83ad24cbc6dc8ba3ab746b8e"

  depends_on "gnupg" => :test
  depends_on "pass"
  depends_on "python@3.8"

  resource "pyxdg" do
    url "https://files.pythonhosted.org/packages/47/6e/311d5f22e2b76381719b5d0c6e9dc39cd33999adae67db71d7279a6d70f4/pyxdg-0.26.tar.gz"
    sha256 "fe2928d3f532ed32b39c32a482b54136fe766d19936afc96c8f00645f9da1a06"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    require "open3"

    ENV["GNUPGHOME"] = testpath/".gnupg"
    ENV["PASSWORD_STORE_DIR"] = testpath/".password-store"

    # Generate temporary GPG key for use with pass
    Open3.popen3(Formula["gnupg"].opt_bin/"gpg", "--generate-key", "--batch") do |stdin, _|
      stdin.write <<~EOS
        %no-protection
        %transient-key
        Key-Type: RSA
        Name-Real: Homebrew Test
      EOS
    end

    system "pass", "init", "Homebrew Test"

    stdin, _ = Open3.popen3("pass", "insert", "-m", "-f", "homebrew/pass-git-helper-test")
    stdin.write <<~EOS
      test_password
      test_username
    EOS
    stdin.close

    (testpath/"config.ini").write <<~EOS
      [github.com*]
      target=homebrew/pass-git-helper-test
    EOS

    stdin, stdout, _ = Open3.popen3(bin/"pass-git-helper", "-m", testpath/"config.ini", "get")
    stdin.write <<~EOS
      protocol=https
      host=github.com
      path=homebrew/homebrew-core
    EOS
    stdin.close

    assert_match "password=test_password\nusername=test_username", stdout.read
    stdout.close
  end
end
