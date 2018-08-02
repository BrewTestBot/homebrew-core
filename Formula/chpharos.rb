class Chpharos < Formula
  desc "Kontena Pharos tool chain version installer and switcher"
  homepage "https://github.com/kontena/chpharos#readme"
  url "https://github.com/kontena/chpharos/archive/v0.1.1.tar.gz"
  sha256 "0f4ab62996416bf290909dd1638caf2dd224069d6218222ce0969141f289ca15"
  head "https://github.com/kontena/chpharos.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "d96d079670db930f5c0c58ea0c9ec984369e6eeda84dbbd4ba2e6aae9cf0788c" => :high_sierra
    sha256 "d96d079670db930f5c0c58ea0c9ec984369e6eeda84dbbd4ba2e6aae9cf0788c" => :sierra
    sha256 "d96d079670db930f5c0c58ea0c9ec984369e6eeda84dbbd4ba2e6aae9cf0788c" => :el_capitan
  end

  def install
    system "make", "install", "PREFIX=#{prefix}"
    bash_completion.install "opt/bash-completion.sh" => "chpharos-completion.bash"
    zsh_completion.install_symlink bash_completion/"chpharos-completion.bash" => "_chpharos"
  end

  def caveats; <<~EOS
    Add the following to the ~/.bash_profile or ~/.zshrc file:
      source #{opt_pkgshare}/chpharos.sh

    To enable auto-switching of Pharos versions specified by .pharos-version files,
    add the following to ~/.bash_profile or ~/.zshrc:
      chpharos auto
  EOS
  end

  test do
    assert_equal "chpharos-exec #{version}", shell_output("#{bin}/chpharos-exec --version").strip
  end
end
