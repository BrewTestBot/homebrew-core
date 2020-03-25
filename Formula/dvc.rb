class Dvc < Formula
  include Language::Python::Virtualenv

  desc "Git for data science projects"
  homepage "https://dvc.org"
  url "https://github.com/iterative/dvc/archive/0.91.0.tar.gz"
  sha256 "49d043612fa58a28964b791a1ec40c2f72862ed6e77118fde40141e99d719ed0"

  bottle do
    cellar :any
    sha256 "c7e7a9826aa78d76ae122dd80d33ab86592324f9205dc79e974d020c3ca93139" => :catalina
    sha256 "99b1836cd3482790be96c8153fe5e9ba561df5b15788cce3829854b66e1b7ba5" => :mojave
    sha256 "d5375822e87df0bcd4947c66b312ef9cc580c95d96f409aae34bfc8bf61e10b2" => :high_sierra
  end

  depends_on "pkg-config" => :build
  depends_on "apache-arrow"
  depends_on "openssl@1.1"
  # `apache-arrow` currently depends on Python 3.7
  depends_on "python"

  def install
    venv = virtualenv_create(libexec, "python3")

    system libexec/"bin/pip", "install",
      "--no-binary", ":all:",
      # NOTE: we will uninstall Pillow anyway, so there is no need to build it
      # from source.
      "--only-binary", "Pillow",
      "--ignore-installed",
      # NOTE: pyarrow is already installed as a part of apache-arrow package,
      # so we don't need to specify `hdfs` option.
      ".[gs,s3,azure,oss,ssh,gdrive]"

    # NOTE: dvc depends on asciimatics, which depends on Pillow, which
    # uses liblcms2.2.dylib that causes troubles on mojave. See [1]
    # and [2] for more info. As a workaround, we need to simply
    # uninstall Pillow.
    #
    # [1] https://github.com/peterbrittain/asciimatics/issues/95
    # [2] https://github.com/iterative/homebrew-dvc/issues/9
    system libexec/"bin/pip", "uninstall", "-y", "Pillow"
    system libexec/"bin/pip", "uninstall", "-y", "dvc"

    # NOTE: dvc uses this file [1] to know which package it was installed from,
    # so that it is able to provide appropriate instructions for updates.
    # [1] https://github.com/iterative/dvc/blob/0.68.1/dvc/utils/pkg.py
    File.open("dvc/utils/build.py", "w+") { |file| file.write("PKG = \"brew\"") }

    venv.pip_install_and_link buildpath

    bash_completion.install "scripts/completion/dvc.bash" => "dvc"
    zsh_completion.install "scripts/completion/dvc.zsh"
  end

  test do
    system "#{bin}/dvc", "--version"
  end
end
