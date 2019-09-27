class Pssh < Formula
  include Language::Python::Virtualenv
  desc "Parallel versions of OpenSSH and related tools"
  homepage "https://code.google.com/archive/p/parallel-ssh/"
  url "https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/parallel-ssh/pssh-2.3.1.tar.gz"
  sha256 "539f8d8363b722712310f3296f189d1ae8c690898eca93627fc89a9cb311f6b4"

  bottle do
    cellar :any_skip_relocation
    sha256 "c1fd4fa8d8ecf0d14653822cba442d183a8a2d79b016ecab5c54e565c6972ed2" => :mojave
    sha256 "ce781e0051a5a1855088a25df9eeb828b7a4bbbdafff90b2713c557acba2b19d" => :high_sierra
    sha256 "b4a9f92943bcfb34d5230d90658176ef5fe3a304f3abe48a1aad5fbda38c8efb" => :sierra
    sha256 "b13dcf5091ba493f21cd44c9ef43d028a4e23627b7b855ab4d299f0d543037a1" => :el_capitan
    sha256 "16f3c0b42cd3bfabea6a22a39b62299de53e1fb894b72da0c12574f25a09963a" => :yosemite
    sha256 "62595390d018a9a953928cf6adf8e9299b92f00c3846d74757a18437abbc5f27" => :mavericks
  end

  depends_on "python"

  conflicts_with "putty", :because => "both install `pscp` binaries"

  def install
    # Fixes import error with python3, see https://github.com/lilydjwg/pssh/issues/70
    # fixed in master, should be removed for versions > 2.3.1
    inreplace "psshlib/cli.py", "import version", "from psshlib import version"

    virtualenv_create(libexec, "python3")
    virtualenv_install_with_resources
  end

  test do
    system bin/"pssh", "--version"
  end
end
