class AnsibleCmdb < Formula
  desc "Generates static HTML overview page from Ansible facts"
  homepage "https://github.com/fboender/ansible-cmdb"
  url "https://github.com/fboender/ansible-cmdb/releases/download/1.19/ansible-cmdb-1.19.zip"
  sha256 "a77237344abda87b5811fb7c0941b15be314482cb1851647229c577c720b4e45"

  bottle do
    cellar :any_skip_relocation
    sha256 "a660ede2ff58a3de356c3d973a6cb053eaecca6d634ce140b2aed73069314c7f" => :sierra
    sha256 "6eed3df2edd78dbd2bdf7320830f241e191114cfdebf4f741783c8ab8d91db21" => :el_capitan
    sha256 "6eed3df2edd78dbd2bdf7320830f241e191114cfdebf4f741783c8ab8d91db21" => :yosemite
  end

  depends_on :python if MacOS.version <= :snow_leopard
  depends_on "libyaml"

  def install
    bin.mkpath
    man1.mkpath
    inreplace "Makefile" do |s|
      s.gsub! "/usr/local/lib/${PROG}", prefix
      s.gsub! "/usr/local/bin", bin
      s.gsub! "/usr/local/share/man/man1", man1
    end
    system "make", "install"
  end

  test do
    system bin/"ansible-cmdb", "-dt", "html_fancy", "."
  end
end
