class Docutils < Formula
  include Language::Python::Virtualenv

  desc "Text processing system for reStructuredText"
  homepage "https://docutils.sourceforge.io"
  url "https://downloads.sourceforge.net/project/docutils/docutils/0.15/docutils-0.15.tar.gz"
  sha256 "c35e87e985f70106f6f97e050f3bed990641e0e104566134b9cd23849a460e96"

  bottle do
    cellar :any_skip_relocation
    sha256 "71bc62531fd234add02633a69b12c2f1f43d6799d5ab1615ab6c9b22064803cc" => :mojave
    sha256 "5f317d1324dd57a4053c3feb518463ed6e67e13589f94f5738a528d63daa6770" => :high_sierra
    sha256 "a91be71816c677dac34fe253695440bebaf54d634652622ca1e797f5cebecbee" => :sierra
  end

  depends_on "python"

  def install
    virtualenv_install_with_resources
  end

  test do
    system "#{bin}/rst2man.py", "#{prefix}/HISTORY.txt"
  end
end
