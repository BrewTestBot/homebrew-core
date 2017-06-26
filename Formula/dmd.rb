class Dmd < Formula
  desc "D programming language compiler for macOS"
  homepage "https://dlang.org/"

  stable do
    url "https://github.com/dlang/dmd/archive/v2.074.1.tar.gz"
    sha256 "1e4191beaa6cce4ebf1810e01884b646b3bac7b098e1ae577a7f55be59dfc336"

    resource "druntime" do
      url "https://github.com/dlang/druntime/archive/v2.074.1.tar.gz"
      sha256 "c1171677ed1a3803e751feeacd8df82288872f78a5170471b7ca7c61631348cd"
    end

    resource "phobos" do
      url "https://github.com/dlang/phobos/archive/v2.074.1.tar.gz"
      sha256 "2bec9f067256c7a1a8fcf62f8a59ae82f094479cfac0e385280afc6af23cbea8"
    end

    resource "tools" do
      url "https://github.com/dlang/tools/archive/v2.074.1.tar.gz"
      sha256 "2fbaf425554210786b865d1e468698d46c48462b118a25a201ce1865445b217b"
    end
  end

  bottle do
    rebuild 1
    sha256 "1ac09a6ced4c56abd84beaa1814a92f905aa21cf2aeb0c7b4151e5321e5c914d" => :sierra
    sha256 "497005cc771c64d89e259f21687f93a4273431aa3e15b1290be86a9b462f00a0" => :el_capitan
    sha256 "71f273f77cd3ae97227fcbcb14278bd8cf16b7e57cb936842188dce5110df277" => :yosemite
  end

  devel do
    url "https://github.com/dlang/dmd/archive/v2.075.0-b1.tar.gz"
    version "2.075.0-b1"
    sha256 "d11a65e89c52e9dab6265599d2bdeb2c270089bc4dffd2ec089331d64b7dc90a"

    resource "druntime" do
      url "https://github.com/dlang/druntime/archive/v2.075.0-b1.tar.gz"
      version "2.075.0-b1"
      sha256 "cdf7f44e5958d268c8e3bda5116866c64cb7a1a87ced7dcfe53209db5e311620"
    end

    resource "phobos" do
      url "https://github.com/dlang/phobos/archive/v2.075.0-b1.tar.gz"
      version "2.075.0-b1"
      sha256 "7613212a4fe373abe88e2c718c621befa0d6a760acc02484b4f763792ecf3747"
    end

    resource "tools" do
      url "https://github.com/dlang/tools/archive/v2.075.0-b1.tar.gz"
      version "2.075.0-b1"
      sha256 "6811d4237810bdf20d9661ba41b006e82f514a73f5425847b504a12dfc7178f0"
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

    # A proper dmd.conf is required for later build steps:
    conf = buildpath/"dmd.conf"
    # Can't use opt_include or opt_lib here because dmd won't have been
    # linked into opt by the time this build runs:
    conf.write <<-EOS.undent
        [Environment]
        DFLAGS=-I#{include}/dlang/dmd -L-L#{lib}
        EOS
    etc.install conf
    install_new_dmd_conf

    make_args.unshift "DMD=#{bin}/dmd"

    (buildpath/"druntime").install resource("druntime")
    (buildpath/"phobos").install resource("phobos")

    system "make", "-C", "druntime", *make_args
    system "make", "-C", "phobos", "VERSION=#{buildpath}/VERSION", *make_args

    (include/"dlang/dmd").install Dir["druntime/import/*"]
    cp_r ["phobos/std", "phobos/etc"], include/"dlang/dmd"
    lib.install Dir["druntime/lib/*", "phobos/**/libphobos2.a"]

    resource("tools").stage do
      inreplace "posix.mak", "install: $(TOOLS) $(CURL_TOOLS)", "install: $(TOOLS) $(ROOT)/dustmite"
      system "make", "install", *make_args
    end
  end

  # Previous versions of this formula may have left in place an incorrect
  # dmd.conf.  If it differs from the newly generated one, move it out of place
  # and warn the user.
  # This must be idempotent because it may run from both install() and
  # post_install() if the user is running `brew install --build-from-source`.
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
