class Pipenv < Formula
  include Language::Python::Virtualenv

  desc "Python dependency management tool"
  homepage "https://docs.pipenv.org/"
  url "https://files.pythonhosted.org/packages/11/06/df6c713c9522da6e5ffd2ec5f4bf4a5b131da91acdab1d64ad4411f5b87f/pipenv-2018.10.9.tar.gz"
  sha256 "92e0c79ed941988f817e47611eae163508dd5e658a905da9aa0677b995531a2c"

  bottle do
    cellar :any_skip_relocation
    rebuild 1
    sha256 "9f0749fdea23455d4aaaf713b6fb9c55cede25e7fdb2f3ba4a3adcefa9bb20b3" => :mojave
    sha256 "8b42b0419a18915dc2ff1caf1e45adb9b265ee7ecd5956b340f94ad385855dd9" => :high_sierra
    sha256 "d211007d8bb65a1e5bf7011bd7b47dc1f96b91454a486138a555c62389328694" => :sierra
  end

  depends_on "python"

  resource "certifi" do
    url "https://files.pythonhosted.org/packages/e1/0f/f8d5e939184547b3bdc6128551b831a62832713aa98c2ccdf8c47ecc7f17/certifi-2018.8.24.tar.gz"
    sha256 "376690d6f16d32f9d1fe8932551d80b23e9d393a8578c5633a2ed39a64861638"
  end

  resource "virtualenv" do
    url "https://files.pythonhosted.org/packages/33/bc/fa0b5347139cd9564f0d44ebd2b147ac97c36b2403943dbee8a25fd74012/virtualenv-16.0.0.tar.gz"
    sha256 "ca07b4c0b54e14a91af9f34d0919790b016923d157afda5efdde55c96718f752"
  end

  resource "virtualenv-clone" do
    url "https://files.pythonhosted.org/packages/14/2f/84b6a8e380439cdfdb71e0ced2a805a66e343ac540d3304bde6bc28fbb46/virtualenv-clone-0.3.0.tar.gz"
    sha256 "b5cfe535d14dc68dfc1d1bb4ac1209ea28235b91156e2bba8e250d291c3fb4f8"
  end

  def install
    # Using the virtualenv DSL here because the alternative of using
    # write_env_script to set a PYTHONPATH breaks things.
    # https://github.com/Homebrew/homebrew-core/pull/19060#issuecomment-338397417
    venv = virtualenv_create(libexec, "python3")
    venv.pip_install resources
    venv.pip_install buildpath

    # `pipenv` needs to be able to find `virtualenv` and `pewtwo` on PATH. So we
    # install symlinks for those scripts in `#{libexec}/tools` and create a
    # wrapper script for `pipenv` which adds `#{libexec}/tools` to PATH.
    (libexec/"tools").install_symlink libexec/"bin/pewtwo", libexec/"bin/pip",
                                      libexec/"bin/virtualenv"
    env = {
      :PATH => "#{libexec}/tools:$PATH",
    }
    (bin/"pipenv").write_env_script(libexec/"bin/pipenv", env)

    output = Utils.popen_read("#{libexec}/bin/pipenv --completion")
    (bash_completion/"pipenv").write output
  end

  # Avoid relative paths
  def post_install
    lib_python_path = Pathname.glob(libexec/"lib/python*").first
    lib_python_path.each_child do |f|
      next unless f.symlink?
      realpath = f.realpath
      rm f
      ln_s realpath, f
    end
    py = Formula["python"]
    inreplace lib_python_path/"orig-prefix.txt",
              py.opt_prefix,
              py.prefix(py.linked_version).realpath
  end

  test do
    ENV["LC_ALL"] = "en_US.UTF-8"
    assert_match "Commands", shell_output("#{bin}/pipenv")
    system "#{bin}/pipenv", "install", "requests"
    system "#{bin}/pipenv", "install", "boto3"
    assert_predicate testpath/"Pipfile", :exist?
    assert_predicate testpath/"Pipfile.lock", :exist?
    assert_match "requests", (testpath/"Pipfile").read
    assert_match "boto3", (testpath/"Pipfile").read
  end
end
