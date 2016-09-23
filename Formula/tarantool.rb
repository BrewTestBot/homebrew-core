class Tarantool < Formula
  desc "In-memory database and Lua application server."
  homepage "https://tarantool.org/"
  url "http://download.tarantool.org/tarantool/1.6/src/tarantool-1.6.8.772.tar.gz"
  version "1.6.8-772"
  sha256 "e07913d3416fcf855071e7b82eed0c5bcdb81a6e587fa2d900a9755ed5bb220c"
  revision 1

  head "https://github.com/tarantool/tarantool.git", branch: "1.7", shallow: false

  bottle do
    sha256 "cda868dffc52e4daca4c660ff70774232a3cf4ec515d57efb0ef5f1332b9a52a" => :sierra
    sha256 "82943bf09ef8f936583e76a0826980fe9e55903629368f10b79aaf9b940be3d0" => :el_capitan
    sha256 "0c01933e0bab178ecb9115b8b010554e49a11c09d94e185c9c83534605be8936" => :yosemite
  end

  depends_on "cmake" => :build
  depends_on "openssl"
  depends_on "readline"

  def install
    args = std_cmake_args

    # Fix "dyld: lazy symbol binding failed: Symbol not found: _clock_gettime"
    # Reported 19 Sep 2016 https://github.com/tarantool/tarantool/issues/1777
    if MacOS.version == "10.11" && MacOS::Xcode.installed? && MacOS::Xcode.version >= "8.0"
      args << "-DHAVE_CLOCK_GETTIME:INTERNAL=0"
      inreplace "src/trivia/util.h", "#ifndef HAVE_CLOCK_GETTIME",
                                     "#ifdef UNDEFINED_GIBBERISH"
    end

    args << "-DCMAKE_INSTALL_MANDIR=#{doc}"
    args << "-DCMAKE_INSTALL_SYSCONFDIR=#{etc}"
    args << "-DCMAKE_INSTALL_LOCALSTATEDIR=#{var}"
    args << "-DENABLE_DIST=ON"
    args << "-DOPENSSL_ROOT_DIR=#{Formula["openssl"].opt_prefix}"

    system "cmake", ".", *args
    system "make"
    system "make", "install"
  end

  def post_install
    local_user = ENV["USER"]
    inreplace etc/"default/tarantool", /(username\s*=).*/, "\\1 '#{local_user}'"

    (var/"lib/tarantool").mkpath
    (var/"log/tarantool").mkpath
    (var/"run/tarantool").mkpath
  end

  test do
    (testpath/"test.lua").write <<-EOS.undent
        box.cfg{}
        local s = box.schema.create_space("test")
        s:create_index("primary")
        local tup = {1, 2, 3, 4}
        s:insert(tup)
        local ret = s:get(tup[1])
        if (ret[3] ~= tup[3]) then
          os.exit(-1)
        end
        os.exit(0)
    EOS
    system bin/"tarantool", "#{testpath}/test.lua"
  end
end
