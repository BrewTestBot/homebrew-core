class Rocksdb < Formula
  desc "Embeddable, persistent key-value store for fast storage"
  homepage "https://rocksdb.org/"
  url "https://github.com/facebook/rocksdb/archive/v5.13.4.tar.gz"
  sha256 "a1e1df858124961d9211134c98925cd478fd1c1863d38685fd74f42c44b656c2"

  bottle do
    cellar :any
    sha256 "4bf61e3fed782125a8ff1501a53c02d1098faf742a2bd98b630fbd2028db02eb" => :high_sierra
    sha256 "3054f4d7516111df1c7f3ca9d135634b80d3b70b28d70de8d9f683ad53f1f5df" => :sierra
    sha256 "a5971ece081d2c654dc09673f8c8ffe379f2576c2fa3c75fd2479d9fadc8aa0a" => :el_capitan
  end

  needs :cxx11
  depends_on "snappy"
  depends_on "lz4"
  depends_on "gflags"

  def install
    ENV.cxx11
    ENV["PORTABLE"] = "1" if build.bottle?
    ENV["DEBUG_LEVEL"] = "0"
    ENV["USE_RTTI"] = "1"
    ENV["DISABLE_JEMALLOC"] = "1" # prevent opportunistic linkage

    # build regular rocksdb
    system "make", "clean"
    system "make", "static_lib"
    system "make", "shared_lib"
    system "make", "tools"
    system "make", "install", "INSTALL_PATH=#{prefix}"

    bin.install "sst_dump" => "rocksdb_sst_dump"
    bin.install "db_sanity_test" => "rocksdb_sanity_test"
    bin.install "db_stress" => "rocksdb_stress"
    bin.install "write_stress" => "rocksdb_write_stress"
    bin.install "ldb" => "rocksdb_ldb"
    bin.install "db_repl_stress" => "rocksdb_repl_stress"
    bin.install "rocksdb_dump"
    bin.install "rocksdb_undump"

    # build rocksdb_lite
    ENV.append_to_cflags "-DROCKSDB_LITE=1"
    ENV["LIBNAME"] = "librocksdb_lite"
    system "make", "clean"
    system "make", "static_lib"
    system "make", "shared_lib"
    system "make", "install", "INSTALL_PATH=#{prefix}"
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <assert.h>
      #include <rocksdb/options.h>
      #include <rocksdb/memtablerep.h>
      using namespace rocksdb;
      int main() {
        Options options;
        return 0;
      }
    EOS

    system ENV.cxx, "test.cpp", "-o", "db_test", "-v",
                                "-std=c++11", "-stdlib=libc++", "-lstdc++",
                                "-lz", "-lbz2",
                                "-L#{lib}", "-lrocksdb_lite",
                                "-L#{Formula["snappy"].opt_lib}", "-lsnappy",
                                "-L#{Formula["lz4"].opt_lib}", "-llz4"
    system "./db_test"

    assert_match "sst_dump --file=", shell_output("#{bin}/rocksdb_sst_dump --help 2>&1", 1)
    assert_match "rocksdb_sanity_test <path>", shell_output("#{bin}/rocksdb_sanity_test --help 2>&1", 1)
    assert_match "rocksdb_stress [OPTIONS]...", shell_output("#{bin}/rocksdb_stress --help 2>&1", 1)
    assert_match "rocksdb_write_stress [OPTIONS]...", shell_output("#{bin}/rocksdb_write_stress --help 2>&1", 1)
    assert_match "ldb - RocksDB Tool", shell_output("#{bin}/rocksdb_ldb --help 2>&1", 1)
    assert_match "rocksdb_repl_stress:", shell_output("#{bin}/rocksdb_repl_stress --help 2>&1", 1)
    assert_match "rocksdb_dump:", shell_output("#{bin}/rocksdb_dump --help 2>&1", 1)
    assert_match "rocksdb_undump:", shell_output("#{bin}/rocksdb_undump --help 2>&1", 1)
  end
end
