class Openldap < Formula
  desc "Open source suite of directory software"
  homepage "https://www.openldap.org/software/"
  url "https://www.openldap.org/software/download/OpenLDAP/openldap-release/openldap-2.4.49.tgz"
  sha256 "e3b117944b4180f23befe87d0dcf47f29de775befbc469dcf4ac3dab3311e56e"

  bottle do
    sha256 "644e0ba997bdc81cddd8906cb7eee96bd44ed7e6ad4a586db6313f13e251b0e2" => :catalina
    sha256 "9094f2a881c3ceebec82e0be185a684ffbed08b05ddca3d6a87c7b730021b351" => :mojave
    sha256 "910f65142bf5df01cc618a8896b51b1cd925e162078afc599256232e2804eb71" => :high_sierra
    sha256 "2f8144b9e6930366b005469d4cc33f57d80048d402a60b3c1f3bf4783139ddd0" => :sierra
  end

  keg_only :provided_by_macos

  depends_on "openssl@1.1"

  def install
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --sysconfdir=#{etc}
      --localstatedir=#{var}
      --enable-accesslog
      --enable-auditlog
      --enable-bdb=no
      --enable-constraint
      --enable-dds
      --enable-deref
      --enable-dyngroup
      --enable-dynlist
      --enable-hdb=no
      --enable-memberof
      --enable-ppolicy
      --enable-proxycache
      --enable-refint
      --enable-retcode
      --enable-seqmod
      --enable-translucent
      --enable-unique
      --enable-valsort
    ]

    system "./configure", *args
    system "make", "install"
    (var/"run").mkpath

    # https://github.com/Homebrew/homebrew-dupes/pull/452
    chmod 0755, Dir[etc/"openldap/*"]
    chmod 0755, Dir[etc/"openldap/schema/*"]
  end

  test do
    system sbin/"slappasswd", "-s", "test"
  end
end
