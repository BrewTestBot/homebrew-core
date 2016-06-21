class Weboob < Formula
  desc "Web Outside of Browsers"
  homepage "http://weboob.org/"
  url "https://symlink.me/attachments/download/324/weboob-1.1.tar.gz"
  sha256 "cbc0d8a88e402ec71a79f0cf09594fd3a969122111f5cd695f4a4ca67961661c"
  revision 1

  head "https://git.symlink.me/pub/weboob/stable.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "3c7bdcc022f07724edbb128c97f239261fd8c0139c9292db1afc9bf5c34d7669" => :el_capitan
    sha256 "3aac436209bcdcc237390434779a12a833950990c78ebea511fd25f329c5c1fe" => :yosemite
    sha256 "a72d292237defb20555a9520e4cf5f6d3b73ae1e5905167ef637c3a363efc346" => :mavericks
  end

  depends_on :python if MacOS.version <= :snow_leopard
  depends_on "libyaml"
  depends_on "pyqt"
  depends_on :gpg => :run

  resource "termcolor" do
    url "https://pypi.python.org/packages/source/t/termcolor/termcolor-1.1.0.tar.gz"
    sha256 "1d6d69ce66211143803fbc56652b41d73b4a400a2891d7bf7a1cdf4c02de613b"
  end

  resource "requests" do
    url "https://pypi.python.org/packages/source/r/requests/requests-2.7.0.tar.gz"
    sha256 "398a3db6d61899d25fd4a06c6ca12051b0ce171d705decd7ed5511517b4bb93d"
  end

  resource "mechanize" do
    url "https://pypi.python.org/packages/source/m/mechanize/mechanize-0.2.5.tar.gz"
    sha256 "2e67b20d107b30c00ad814891a095048c35d9d8cb9541801cebe85684cc84766"
  end

  resource "prettytable" do
    url "https://pypi.python.org/packages/source/P/PrettyTable/prettytable-0.7.2.tar.bz2"
    sha256 "853c116513625c738dc3ce1aee148b5b5757a86727e67eff6502c7ca59d43c36"
  end

  def install
    ENV.prepend_create_path "PYTHONPATH", libexec/"vendor/lib/python2.7/site-packages"
    resources.each do |r|
      r.stage do
        system "python", *Language::Python.setup_install_args(libexec/"vendor")
      end
    end

    ENV.prepend_create_path "PYTHONPATH", libexec/"lib/python2.7/site-packages"
    system "python", *Language::Python.setup_install_args(libexec)

    bin.install Dir[libexec/"bin/*"]
    bin.env_script_all_files(libexec/"bin", :PYTHONPATH => ENV["PYTHONPATH"])
  end

  test do
    system bin/"weboob-config", "update"
    system bin/"weboob-config", "applications"
  end
end
