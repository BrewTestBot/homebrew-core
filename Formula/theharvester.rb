class Theharvester < Formula
  desc "Gather materials from public sources (for pen testers)"
  homepage "http://www.edge-security.com/theharvester.php"
  url "https://github.com/laramies/theHarvester/archive/v3.0.1.tar.gz"
  sha256 "0e19a2f18459c9902792648b5fd65449c8702e61094fbb34edeed02bb8899af4"
  head "https://github.com/laramies/theHarvester.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "f55ac2899478e80d4137b3ff87660b15b551c0db1a7828c3a42f4dc08d8959c0" => :mojave
    sha256 "fac32ee928f4125471613b337ffcef023f4e6924f6618fa340c67d6ba9e5a137" => :high_sierra
    sha256 "926a441d788bc21e4cfdebb9b98c5a69f06f2bc9f1d0c4763ebb0cd6301f3597" => :sierra
    sha256 "eb8efb01299ff3a4581e733ec1b7d7d27c42d88d10e2b31cf78f109cb61c4031" => :el_capitan
    sha256 "a3712887bea4ea3586d39672cb0b194588694de050aa7f1bd762df5cba463fba" => :yosemite
    sha256 "56c3d5b41a821be12fc6f27ac8beb266984f0c245495c9970614ed776107633f" => :mavericks
  end

  depends_on "python"

  resource "requests" do
    url "https://files.pythonhosted.org/packages/49/6f/183063f01aae1e025cf0130772b55848750a2f3a89bfa11b385b35d7329d/requests-2.10.0.tar.gz"
    sha256 "63f1815788157130cee16a933b2ee184038e975f0017306d723ac326b5525b54"
  end

  def install
    xy = Language::Python.major_minor_version "python3"
    ENV["PYTHONPATH"] = libexec/"lib/python#{xy}/site-packages"
    ENV.prepend_create_path "PYTHONPATH", libexec/"vendor/lib/python#{xy}/site-packages"

    resources.each do |r|
      r.stage do
        system "python3", *Language::Python.setup_install_args(libexec/"vendor")
      end
    end

    libexec.install Dir["*"]
    (libexec/"theHarvester.py").chmod 0755
    (bin/"theharvester").write_env_script("#{libexec}/theHarvester.py", :PYTHONPATH => ENV["PYTHONPATH"])
  end

  test do
    output = shell_output("#{bin}/theharvester -d brew.sh -l 1 -b pgp 2>&1")
    assert_match "security@brew.sh", output
  end
end
