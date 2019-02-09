class GitExtras < Formula
  desc "Small git utilities"
  homepage "https://github.com/tj/git-extras"
  url "https://github.com/tj/git-extras/archive/4.7.0.tar.gz"
  sha256 "58ed54248a1efcb8e9981940040361343e175cb36f72adc61896d53a8b234b5d"
  head "https://github.com/tj/git-extras.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "da1a027041941fd5dda4c7c0c94f6b539c72ae24136781e4e46ded6ab412e7c5" => :mojave
    sha256 "ea6415e13bd9a84dfbfdd6dbd439180370d52fb7662daa2f7ab22e05d848a9fc" => :high_sierra
    sha256 "ea6415e13bd9a84dfbfdd6dbd439180370d52fb7662daa2f7ab22e05d848a9fc" => :sierra
    sha256 "ea6415e13bd9a84dfbfdd6dbd439180370d52fb7662daa2f7ab22e05d848a9fc" => :el_capitan
  end

  conflicts_with "git-utils",
    :because => "both install a `git-pull-request` script"

  def install
    system "make", "PREFIX=#{prefix}", "INSTALL_VIA=brew", "install"
    pkgshare.install "etc/git-extras-completion.zsh"
  end

  def caveats; <<~EOS
    To load Zsh completions, add the following to your .zschrc:
      source #{opt_pkgshare}/git-extras-completion.zsh
  EOS
  end

  test do
    system "git", "init"
    assert_match(/#{testpath}/, shell_output("#{bin}/git-root"))
  end
end
