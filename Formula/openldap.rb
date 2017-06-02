class Openldap < Formula
  desc "Open source suite of directory software"
  homepage "https://www.openldap.org/software/"
  url "https://www.openldap.org/software/download/OpenLDAP/openldap-release/openldap-2.4.45.tgz"
  mirror "ftp://ftp.openldap.org/pub/OpenLDAP/openldap-release/openldap-2.4.45.tgz"
  sha256 "cdd6cffdebcd95161a73305ec13fc7a78e9707b46ca9f84fb897cd5626df3824"

  bottle do
    sha256 "ab9afee23bf7e736d32aba07e1ce0fab1c72bb080dc28503c08a936de6f14692" => :sierra
    sha256 "c1ee06d8689f17ad24973d419c2327049a0234deb07adc6fedb90cce7a04dae3" => :el_capitan
    sha256 "f94202455020ac274f2a63f2fac2c0919431badb7782294520af1fc60dda5423" => :yosemite
  end

  keg_only :provided_by_osx

  option "with-sssvlv", "Enable server side sorting and virtual list view"

  depends_on "openssl@1.1"
  depends_on "berkeley-db@4" => :optional

  def install
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --sysconfdir=#{etc}
      --localstatedir=#{var}
      --enable-accesslog
      --enable-auditlog
      --enable-constraint
      --enable-dds
      --enable-deref
      --enable-dyngroup
      --enable-dynlist
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

    args << "--enable-bdb=no" << "--enable-hdb=no" if build.without? "berkeley-db@4"
    args << "--enable-sssvlv=yes" if build.with? "sssvlv"

    system "./configure", *args
    system "make", "install"

    # https://github.com/Homebrew/homebrew-dupes/pull/452
    chmod 0755, Dir[etc/"openldap/*"]
    chmod 0755, Dir[etc/"openldap/schema/*"]
  end

  def post_install
    (var/"run").mkpath
  end

  test do
    system sbin/"slappasswd", "-s", "test"
  end
end
