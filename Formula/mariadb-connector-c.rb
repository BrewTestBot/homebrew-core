class MariadbConnectorC < Formula
  desc "MariaDB database connector for C applications"
  homepage "https://downloads.mariadb.org/connector-c/"
  url "https://downloads.mariadb.org/f/connector-c-3.1.5/mariadb-connector-c-3.1.5-src.tar.gz"
  sha256 "a9de5fedd1a7805c86e23be49b9ceb79a86b090ad560d51495d7ba5952a9d9d5"

  bottle do
    sha256 "85cd4eac75f693602a4cb4cd8b17cd26a71d3df3e147ba28f40e605fcd1cacb5" => :catalina
    sha256 "b64eb44ed34e785ccb71b71452d0a7073409ffb589c1b33fe49de6bc9a031820" => :mojave
    sha256 "50663d29b7cf483e8bbf554f329110c79939fdba54850c9e046d6460d992429f" => :high_sierra
    sha256 "98f0045250155bbf5cc2dd34771f76bb54544496a6b63ce2f61032f9cfd22a43" => :sierra
  end

  depends_on "cmake" => :build
  depends_on "openssl@1.1"

  conflicts_with "mysql", "mariadb", "percona-server",
                 :because => "both install plugins"

  def install
    args = std_cmake_args
    args << "-DWITH_OPENSSL=On"
    args << "-DOPENSSL_INCLUDE_DIR=#{Formula["openssl@1.1"].opt_include}"
    args << "-DCOMPILATION_COMMENT=Homebrew"

    system "cmake", ".", *args
    system "make", "install"
  end

  test do
    system "#{bin}/mariadb_config", "--cflags"
  end
end
