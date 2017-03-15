class Gpgme < Formula
  desc "Library access to GnuPG"
  homepage "https://www.gnupg.org/related_software/gpgme/"
  url "https://www.gnupg.org/ftp/gcrypt/gpgme/gpgme-1.9.0.tar.bz2"
  mirror "https://www.mirrorservice.org/sites/ftp.gnupg.org/gcrypt/gpgme/gpgme-1.9.0.tar.bz2"
  sha256 "1b29fedb8bfad775e70eafac5b0590621683b2d9869db994568e6401f4034ceb"
  revision 1

  bottle do
    cellar :any
    sha256 "cfd3a2d3545b5eb6533f0328360c9fe0c00fe202ec671381f1cffdc4228d8985" => :sierra
    sha256 "20c4cfe446f6695f61b58ef0ded8e7e97f859ed085ae105dbb8bc6126674a361" => :el_capitan
    sha256 "a03901f80688be594dbf6943faaa1a72548634e2c52b5946fdd0cc12f846ab4f" => :yosemite
  end

  depends_on "gnupg"
  depends_on "libgpg-error"
  depends_on "libassuan"
  depends_on "pth"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--enable-static"
    system "make"
    system "make", "install"

    # avoid triggering mandatory rebuilds of software that hard-codes this path
    inreplace bin/"gpgme-config", prefix, opt_prefix
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/gpgme-tool --lib-version")
  end
end
