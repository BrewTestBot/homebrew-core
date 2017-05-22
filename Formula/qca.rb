class Qca < Formula
  desc "Qt Cryptographic Architecture (QCA)"
  homepage "http://delta.affinix.com/qca/"
  head "https://anongit.kde.org/qca.git"
  revision 1

  stable do
    url "https://github.com/KDE/qca/archive/v2.1.3.tar.gz"
    sha256 "a5135ffb0250a40e9c361eb10cd3fe28293f0cf4e5c69d3761481eafd7968067"

    # upstream fixes for macOS building (remove on 2.2.0 upgrade)
    patch do
      url "https://github.com/KDE/qca/commit/7ba0ee591e0f50a7e7b532f9eb7e500e7da784fb.diff"
      sha256 "31977c97ff07d562244211536fa51d0a155b5a13a865a4a231dbb5a15bf3bd61"
    end
    patch do
      url "https://github.com/KDE/qca/commit/b435c1b87b14ac2d2de9f83e586bfd6d8c2a755e.diff"
      sha256 "9f53b78fcdb723522aeea406a44e2229d200f649f60f787911e4ddea8528e5f1"
    end
    patch do
      url "https://github.com/KDE/qca/commit/f4b2eb0ced5310f3c43398eb1f03e0c065e08a82.diff"
      sha256 "4bcffdbdd4cbf216861290f10010da15ceae1bc2470e69c31930e3e59d57deb7"
    end

    # use major version for framework, instead of full version
    # see: https://github.com/KDE/qca/pull/3
    patch do
      url "https://github.com/KDE/qca/pull/3.patch"
      sha256 "4972c941df8eee0b974d3cf01211ebc9650c6fba8dca9be6b2567fdd86c25785"
    end
  end

  bottle do
    rebuild 1
    sha256 "218d742b0de9c279b706b9a9ade7012ce20b912cc57dbc22a8d2c7723d2cb4b3" => :sierra
    sha256 "9f9425ca00fba5468410d56397abbf4817c26d3430acf3a025edf052126103d5" => :el_capitan
    sha256 "1f27366c7643a79fd07315e6f3e5c64355cde3fecabfdfdd527f53027d7e5daa" => :yosemite
  end

  option "with-api-docs", "Build API documentation"

  deprecated_option "with-gnupg" => "with-gpg2"

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "qt"

  # Plugins (QCA needs at least one plugin to do anything useful)
  depends_on "openssl" # qca-ossl
  depends_on "botan" => :optional # qca-botan
  depends_on "libgcrypt" => :optional # qca-gcrypt
  depends_on :gpg => [:optional, :run] # qca-gnupg
  depends_on "nss" => :optional # qca-nss
  depends_on "pkcs11-helper" => :optional # qca-pkcs11

  if build.with? "api-docs"
    depends_on "graphviz" => :build
    depends_on "doxygen" => [:build, "with-graphviz"]
  end

  def install
    args = std_cmake_args
    args << "-DQT4_BUILD=OFF"
    args << "-DBUILD_TESTS=OFF"

    # Plugins (qca-ossl, qca-cyrus-sasl, qca-logger, qca-softstore always built)
    args << "-DWITH_botan_PLUGIN=#{build.with?("botan") ? "YES" : "NO"}"
    args << "-DWITH_gcrypt_PLUGIN=#{build.with?("libgcrypt") ? "YES" : "NO"}"
    args << "-DWITH_gnupg_PLUGIN=#{build.with?("gpg2") ? "YES" : "NO"}"
    args << "-DWITH_nss_PLUGIN=#{build.with?("nss") ? "YES" : "NO"}"
    args << "-DWITH_pkcs11_PLUGIN=#{build.with?("pkcs11-helper") ? "YES" : "NO"}"

    # ensure opt_lib for framework install name and linking (can't be done via CMake configure)
    inreplace "src/CMakeLists.txt",
              /^(\s+)(INSTALL_NAME_DIR )("\$\{QCA_LIBRARY_INSTALL_DIR\}")$/,
             "\\1\\2\"#{opt_lib}\""

    system "cmake", ".", *args
    system "make", "install"

    if build.with? "api-docs"
      system "make", "doc"
      doc.install "apidocs/html"
    end
  end

  test do
    system bin/"qcatool-qt5", "--noprompt", "--newpass=",
                              "key", "make", "rsa", "2048", "test.key"
  end
end
