class Mackup < Formula
  desc "Keep your Mac's application settings in sync"
  homepage "https://github.com/lra/mackup"
  url "https://github.com/lra/mackup/archive/0.8.16.tar.gz"
  sha256 "d50a19be1c6a5b6a777ddfb4abbc6c76a361b3edce266f1618947ad38a100331"

  head "https://github.com/lra/mackup.git"

  bottle do
    cellar :any_skip_relocation
    rebuild 1
    sha256 "5e2c38241893a66950a0e9d3bc9f6628b8a43461efa7d2f8454598a4c1b2a7d2" => :high_sierra
    sha256 "5e2c38241893a66950a0e9d3bc9f6628b8a43461efa7d2f8454598a4c1b2a7d2" => :sierra
    sha256 "5aca72e4968f7d3afcbdbba55905b4d38f09e8d81656744625cc8310f9749fbe" => :el_capitan
  end

  depends_on "python" if MacOS.version <= :snow_leopard

  resource "docopt" do
    url "https://files.pythonhosted.org/packages/source/d/docopt/docopt-0.6.2.tar.gz"
    sha256 "49b3a825280bd66b3aa83585ef59c4a8c82f2c8a522dbe754a8bc8d08c85c491"
  end

  def install
    ENV.prepend_create_path "PYTHONPATH", libexec/"vendor/lib/python2.7/site-packages"
    %w[docopt].each do |r|
      resource(r).stage do
        system "python", *Language::Python.setup_install_args(libexec/"vendor")
      end
    end

    ENV.prepend_create_path "PYTHONPATH", libexec/"lib/python2.7/site-packages"
    system "python", *Language::Python.setup_install_args(libexec)

    bin.install Dir[libexec/"bin/*"]
    bin.env_script_all_files(libexec/"bin", :PYTHONPATH => ENV["PYTHONPATH"])
  end

  test do
    system "#{bin}/mackup", "--help"
  end
end
