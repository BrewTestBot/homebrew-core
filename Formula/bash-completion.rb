# NOTE: version 2 is out, but it requires Bash 4, and macOS ships
# with 3.2.57. If you've upgraded bash, use bash-completion@2 instead.
class BashCompletion < Formula
  desc "Programmable completion for Bash 3.2"
  homepage "https://salsa.debian.org/debian/bash-completion"
  url "https://src.fedoraproject.org/repo/pkgs/bash-completion/bash-completion-1.3.tar.bz2/a1262659b4bbf44dc9e59d034de505ec/bash-completion-1.3.tar.bz2"
  sha256 "8ebe30579f0f3e1a521013bcdd183193605dab353d7a244ff2582fb3a36f7bec"
  revision 3

  bottle do
    cellar :any_skip_relocation
    rebuild 1
    sha256 "c7ab91ff667fc27032a3ad128bc2a052018edec829bcceadd32034398d0810e5" => :mojave
    sha256 "4924f6d938bd007862de2311cbad2b70d78ae8f7b397eca6d9ab980f0e7bf86a" => :high_sierra
    sha256 "4924f6d938bd007862de2311cbad2b70d78ae8f7b397eca6d9ab980f0e7bf86a" => :sierra
  end

  conflicts_with "bash-completion@2", :because => "Differing version of same formula"

  # Backports the following upstream patch from 2.x:
  # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=740971
  patch do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/c1d87451da3b5b147bed95b2dc783a1b02520ac5/bash-completion/bug-740971.patch"
    sha256 "bd242a35b8664c340add068bcfac74eada41ed26d52dc0f1b39eebe591c2ea97"
  end

  # Backports (a variant of) an upstream patch to fix man completion.
  patch :DATA

  def install
    inreplace "bash_completion" do |s|
      s.gsub! "/etc/bash_completion", etc/"bash_completion"
      s.gsub! "readlink -f", "readlink"
    end

    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end

  def caveats; <<~EOS
    Add the following line to your ~/.bash_profile:
      [[ -r "#{etc}/profile.d/bash_completion.sh" ]] && . "#{etc}/profile.d/bash_completion.sh"
  EOS
  end

  test do
    system "bash", "-c", ". #{etc}/profile.d/bash_completion.sh"
  end
end
__END__
--- a/completions/man
+++ b/completions/man
@@ -27,7 +27,7 @@
     fi

     uname=$( uname -s )
-    if [[ $uname == @(Linux|GNU|GNU/*|FreeBSD|Cygwin|CYGWIN_*) ]]; then
+    if [[ $uname == @(Darwin|Linux|GNU|GNU/*|FreeBSD|Cygwin|CYGWIN_*) ]]; then
         manpath=$( manpath 2>/dev/null || command man --path )
     else
         manpath=$MANPATH
