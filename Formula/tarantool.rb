class Tarantool < Formula
  desc "In-memory database and Lua application server"
  homepage "https://tarantool.org/"
  url "https://download.tarantool.org/tarantool/1.10/src/tarantool-1.10.4.1.tar.gz"
  sha256 "dc99562840512151beca46d5618e6659b61e0749a99345750b14702f59a868fb"
  version_scheme 1
  head "https://github.com/tarantool/tarantool.git", :branch => "1.10", :shallow => false

  bottle do
    cellar :any
    sha256 "4f1f5e4056407e705307d0eb77f46ddc6b2a17c984a1c5c3071886f8b6af68bf" => :catalina
    sha256 "f92227f316c27b331b7513c23efe105fe1515f75af4a9769bdecf110b738d05d" => :mojave
    sha256 "3597a954d1e9a62d8781312c9f6a41bc8e3282740145d543f3c9487c338db332" => :high_sierra
  end

  depends_on "cmake" => :build
  depends_on "autoconf"
  depends_on "automake"
  depends_on "icu4c"
  depends_on "libtool"
  depends_on "openssl"
  depends_on "readline"

  def install
    sdk = MacOS::CLT.installed? ? "" : MacOS.sdk_path

    # Necessary for luajit to build on macOS Mojave (see luajit formula)
    ENV["MACOSX_DEPLOYMENT_TARGET"] = MacOS.version

    args = std_cmake_args
    args << "-DCMAKE_INSTALL_MANDIR=#{doc}"
    args << "-DCMAKE_INSTALL_SYSCONFDIR=#{etc}"
    args << "-DCMAKE_INSTALL_LOCALSTATEDIR=#{var}"
    args << "-DENABLE_DIST=ON"
    args << "-DOPENSSL_ROOT_DIR=#{Formula["openssl"].opt_prefix}"
    args << "-DREADLINE_ROOT=#{Formula["readline"].opt_prefix}"
    args << "-DCURL_INCLUDE_DIR=#{sdk}/usr/include"
    args << "-DCURL_LIBRARY=/usr/lib/libcurl.dylib"

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
    (testpath/"test.lua").write <<~EOS
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
