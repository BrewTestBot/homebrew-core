class Pympress < Formula
  include Language::Python::Virtualenv

  desc "Simple and powerful dual-screen PDF reader designed for presentations"
  homepage "https://github.com/Cimbali/pympress/"
  url "https://files.pythonhosted.org/packages/35/03/4e655064b30b5717cfed53da88eda098971728fe4c8c94b1599833edbc66/pympress-1.5.1.tar.gz"
  sha256 "8ea3808f31c9ae4152bdcf09632e1fece943d91fc3c974c4c3497ce1984e6d9c"
  head "https://github.com/Cimbali/pympress.git"

  depends_on "gobject-introspection"
  depends_on "gtk+3"
  depends_on "poppler"
  depends_on "pygobject3"
  depends_on "python"

  resource "argh" do
    url "https://files.pythonhosted.org/packages/e3/75/1183b5d1663a66aebb2c184e0398724b624cecd4f4b679cb6e25de97ed15/argh-0.26.2.tar.gz"
    sha256 "e9535b8c84dc9571a48999094fda7f33e63c3f1b74f3e5f3ac0105a58405bb65"
  end

  resource "pathtools" do
    url "https://files.pythonhosted.org/packages/e7/7f/470d6fcdf23f9f3518f6b0b76be9df16dcc8630ad409947f8be2eb0ed13a/pathtools-0.1.2.tar.gz"
    sha256 "7c35c5421a39bb82e58018febd90e3b6e5db34c5443aaaf742b3f33d4655f1c0"
  end

  resource "python-vlc" do
    url "https://files.pythonhosted.org/packages/a8/51/299f4804c43f99d718ed43a63b1ea0712932e25b6bbe1ee1817cb8e954f7/python-vlc-3.0.7110.tar.gz"
    sha256 "821bca0dbe08fbff97a65e56ff2318ad7d499330876579c39f01f3fb38c7b679"
  end

  resource "PyYAML" do
    url "https://files.pythonhosted.org/packages/e3/e8/b3212641ee2718d556df0f23f78de8303f068fe29cdaa7a91018849582fe/PyYAML-5.1.2.tar.gz"
    sha256 "01adf0b6c6f61bd11af6e10ca52b7d4057dd0be0343eb9283c878cf3af56aee4"
  end

  resource "watchdog" do
    url "https://files.pythonhosted.org/packages/bb/e3/5a55d48a29300160779f0a0d2776d17c1b762a2039b36de528b093b87d5b/watchdog-0.9.0.tar.gz"
    sha256 "965f658d0732de3188211932aeb0bb457587f04f63ab4c1e33eab878e9de961d"
  end

  def install
    virtualenv_install_with_resources
    bin.install_symlink libexec/"bin/pympress"
  end

  test do
    system bin/"pympress", "--help"

    # Version info contained in log file only if all dependencies loaded successfully
    assert_predicate testpath/"Library/Logs/pympress.log", :exist?
    output = (testpath/"Library/Logs/pympress.log").read
    assert_match /^INFO:pympress.__main__:Pympress: #{version}\s*;/, output
  end
end
