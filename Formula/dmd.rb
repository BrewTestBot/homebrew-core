class Dmd < Formula
  desc "D programming language compiler for macOS"
  homepage "https://dlang.org/"

  stable do
    url "https://github.com/dlang/dmd/archive/v2.076.1.tar.gz"
    sha256 "242e0dccf0b5aabd3a886c1aca32e6b197dfef015005f45bd36050f8a4fded5c"

    resource "druntime" do
      url "https://github.com/dlang/druntime/archive/v2.076.1.tar.gz"
      sha256 "28950dce412e3bba27030464eb91e99621f4f2c0cd0ba680a6361911776f89b0"
    end

    resource "phobos" do
      url "https://github.com/dlang/phobos/archive/v2.076.1.tar.gz"
      sha256 "d253e6f23d91b8d544dea0b3c8ca4a13abfc2b13642f31f76b6ad2c1dd49615b"
    end

    resource "tools" do
      url "https://github.com/dlang/tools/archive/v2.076.1.tar.gz"
      sha256 "cf42d4e5f9ceb5acfb5bd3000dd9c1ed7120b136f252b33b07fb026f36970e77"
    end
  end

  bottle do
    rebuild 1
    sha256 "7aa2c3a985d4ac2a5f5d4442d1a9d0da1dc41b8fbebd69f020e61d9828565d42" => :high_sierra
    sha256 "1ac8800ee587ee76440d5fa16adcc76bef9a67d56c4122f0d8709a713d90afcc" => :sierra
    sha256 "fa943f7187cc16cb0a5ad5eeffbf0095dd8a3dcbfe8810b14fc919dcac802d22" => :el_capitan
  end

  devel do
    url "https://github.com/dlang/dmd/archive/v2.077.0-beta.2.tar.gz"
    sha256 "398b799c900344c541d13d93cef5c6809391bed01a7191b72da562681e45e2e7"

    resource "druntime" do
      url "https://github.com/dlang/druntime/archive/v2.077.0-beta.2.tar.gz"
      sha256 "a21a5c9833d38b5a56c1a7b59060f8d84bc2ad6826fb4524d898a284120a2a95"
    end

    resource "phobos" do
      url "https://github.com/dlang/phobos/archive/v2.077.0-beta.2.tar.gz"
      sha256 "026f5c52ecee0fe815fd50d8fa230bcf2a35639a2e34964b44e3be01eb3452bb"
    end

    resource "tools" do
      url "https://github.com/dlang/tools/archive/v2.077.0-beta.2.tar.gz"
      sha256 "cc3957e5021fcb3994538d21e765a5a585f9304d48bd370e3b594eb6001d6ef8"
    end
  end

  head do
    url "https://github.com/dlang/dmd.git"

    resource "druntime" do
      url "https://github.com/dlang/druntime.git"
    end

    resource "phobos" do
      url "https://github.com/dlang/phobos.git"
    end

    resource "tools" do
      url "https://github.com/dlang/tools.git"
    end
  end

  def install
    make_args = ["INSTALL_DIR=#{prefix}", "MODEL=#{Hardware::CPU.bits}", "-f", "posix.mak"]

    system "make", "SYSCONFDIR=#{etc}", "TARGET_CPU=X86", "AUTO_BOOTSTRAP=1", "RELEASE=1", *make_args

    bin.install "src/dmd"
    prefix.install "samples"
    man.install Dir["docs/man/*"]

    make_args.unshift "DMD_DIR=#{buildpath}", "DRUNTIME_PATH=#{buildpath}/druntime", "PHOBOS_PATH=#{buildpath}/phobos"
    (buildpath/"druntime").install resource("druntime")
    (buildpath/"phobos").install resource("phobos")
    system "make", "-C", "druntime", *make_args
    system "make", "-C", "phobos", "VERSION=#{buildpath}/VERSION", *make_args

    resource("tools").stage do
      inreplace "posix.mak", "install: $(TOOLS) $(CURL_TOOLS)", "install: $(TOOLS) $(ROOT)/dustmite"
      system "make", "install", *make_args
    end

    (include/"dlang/dmd").install Dir["druntime/import/*"]
    cp_r ["phobos/std", "phobos/etc"], include/"dlang/dmd"
    lib.install Dir["druntime/lib/*", "phobos/**/libphobos2.a"]

    (buildpath/"dmd.conf").write <<~EOS
      [Environment]
      DFLAGS=-I#{opt_include}/dlang/dmd -L-L#{opt_lib}
    EOS
    etc.install "dmd.conf"
  end

  # Previous versions of this formula may have left in place an incorrect
  # dmd.conf.  If it differs from the newly generated one, move it out of place
  # and warn the user.
  def install_new_dmd_conf
    conf = etc/"dmd.conf"

    # If the new file differs from conf, etc.install drops it here:
    new_conf = etc/"dmd.conf.default"
    # Else, we're already using the latest version:
    return unless new_conf.exist?

    backup = etc/"dmd.conf.old"
    opoo "An old dmd.conf was found and will be moved to #{backup}."
    mv conf, backup
    mv new_conf, conf
  end

  def post_install
    install_new_dmd_conf
  end

  test do
    system bin/"dmd", prefix/"samples/hello.d"
    system "./hello"
  end
end
