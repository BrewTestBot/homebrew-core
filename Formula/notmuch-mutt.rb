class NotmuchMutt < Formula
  desc "Notmuch integration for Mutt"
  homepage "https://notmuchmail.org/"
  url "https://notmuchmail.org/releases/notmuch-0.29.3.tar.xz"
  sha256 "d5f704b9a72395e43303de9b1f4d8e14dd27bf3646fdbb374bb3dbb7d150dc35"
  head "https://git.notmuchmail.org/git/notmuch", :using => :git

  depends_on "coreutils" => :build
  depends_on "markdown" => :build
  depends_on "pod2man" => :build
  depends_on "perl"

  patch :DATA

  def install
    # notmuch-mutt Makefile uses GNU specific flags for the `install` command
    ENV.prepend_path "PATH", Formula["coreutils"].opt_libexec/"gnubin"
    system "make", "V=1", "prefix=#{prefix}", "-C", "contrib/notmuch-mutt", "install"
  end

  test do
    system "#{bin}/notmuch-mutt", "search", "Homebrew"
  end
end

__END__
diff --git a/contrib/notmuch-mutt/notmuch-mutt b/contrib/notmuch-mutt/notmuch-mutt
index 0e46a8c1..e4aca8fa 100755
--- a/contrib/notmuch-mutt/notmuch-mutt
+++ b/contrib/notmuch-mutt/notmuch-mutt
@@ -50,7 +50,7 @@ sub search($$$) {
     empty_maildir($maildir);
     system("notmuch search --output=files $dup_option $query"
 	   . " | sed -e 's: :\\\\ :g'"
-	   . " | xargs -r -I searchoutput ln -s searchoutput $maildir/cur/");
+	   . " | while IFS= read -r searchoutput; do ln -s \$searchoutput $maildir/cur/; done");
 }
 
 sub prompt($$) {
