class Yamllint < Formula
  include Language::Python::Virtualenv

  desc "Linter for YAML files"
  homepage "https://github.com/adrienverge/yamllint"
  url "https://github.com/adrienverge/yamllint/archive/v1.11.1.tar.gz"
  sha256 "56221b7c0a50b1619e491eb157624a5d1b160c1a4f019d64f117268f42fe4ca4"

  depends_on "libyaml"
  depends_on "python"

  resource "pyyaml" do
    url "https://files.pythonhosted.org/packages/4a/85/db5a2df477072b2902b0eb892feb37d88ac635d36245a72a6a69b23b383a/PyYAML-3.12.tar.gz"
    sha256 "592766c6303207a20efc445587778322d7f73b161bd994f227adaa341ba212ab"
  end

  resource "pathspec" do
    url "https://files.pythonhosted.org/packages/5e/59/d40bf36fda6cc9ec0e2d2d843986fa7d91f7144ad83e909bcb126b45ea88/pathspec-0.5.6.tar.gz"
    sha256 "be664567cf96a718a68b33329862d1e6f6803ef9c48a6e2636265806cfceb29d"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    # Newline is required at the end for success.
    yaml = <<~EOS
      ---
      foo: bar
    EOS

    # yamllint can't read from stdin, so we need to create a file.
    bad_yaml = (testpath/"bad.yaml")
    # The trailing newline is missing in this YAML. yamllint is silent on
    # success, so we purposely use invalid yaml to test output.
    bad_yaml.write(yaml.chomp)
    output = shell_output("#{bin}/yamllint -f parsable -s #{bad_yaml}", 1).chomp
    expected_output = "#{bad_yaml}:2:9: [error] no new line character at the end of file (new-line-at-end-of-file)"
    assert_equal output, expected_output

    # Verify yamllint can also correctly validate a good yaml file.
    good_yaml = (testpath/"good.yaml")
    good_yaml.write(yaml)
    output = shell_output("#{bin}/yamllint -f parsable -s #{good_yaml}", 0).chomp
    assert_equal output, ""
  end
end
