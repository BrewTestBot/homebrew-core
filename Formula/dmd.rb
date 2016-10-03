class Dmd < Formula
  desc "D programming language compiler for OS X"
  homepage "https://dlang.org/"

  stable do
    url "https://github.com/dlang/dmd/archive/v2.071.2.tar.gz"
    sha256 "bb6195a9cd5351e57ba4dfaf3af3bbf31387a3480306adf2ca317dfc5146cc3f"

    resource "druntime" do
      url "https://github.com/dlang/druntime/archive/v2.071.2.tar.gz"
      sha256 "4a58d1fb8e7427d2302b3830dd5b423cd22b48ad19f7db93c7339d46fd030cda"
    end

    resource "phobos" do
      url "https://github.com/dlang/phobos/archive/v2.071.2.tar.gz"
      sha256 "0cd1ef9f8f92d05f58f93b87271a3cfc2ce9ad156e15069f055e5d1edef98fa4"
    end

    resource "tools" do
      url "https://github.com/dlang/tools/archive/v2.071.2.tar.gz"
      sha256 "392f3766f5f2ac52e19fbacfd37fb9ddba507a53e77fe98f0c5aeca3238ec000"
    end
  end

  bottle do
    rebuild 1
    sha256 "5001c85ed61e4dab53991b4e035f67351037b9f6921f14fdc84fcb01e18ae1b6" => :sierra
    sha256 "98c40203b2e28738313ba4e50396e2a8d29de896db5528402b0007f84a942f09" => :el_capitan
    sha256 "20740c6307ff3204a94c2c1b42e8aae76360b43023e633b7ca7e5dec006e2afa" => :yosemite
  end

  devel do
    url "https://github.com/dlang/dmd/archive/v2.072.0-b1.tar.gz"
    sha256 "017c07c36011256d59d5b91b17a9d315bdc9b07610396d627f4c5b1ff8a6403a"
    version "2.072.0-b1"

    resource "druntime" do
      url "https://github.com/dlang/druntime/archive/v2.072.0-b1.tar.gz"
      sha256 "684732fea3542b8e7dfc6c34dbde421a257dd2630388e44085f064d7acab9e6e"
      version "2.072.0-b1"
    end

    resource "phobos" do
      url "https://github.com/dlang/phobos/archive/v2.072.0-b1.tar.gz"
      sha256 "79050a2e680c87107d53c16d91b5e2e6a679ed61a54c90f3e395af2a7c83b877"
      version "2.072.0-b1"
    end

    resource "tools" do
      url "https://github.com/dlang/tools/archive/v2.072.0-b1.tar.gz"
      sha256 "720faec26b8f0220f3fea166f38ae9e9e2c491dd77a1cf37427b800b6c35f1ea"
      version "2.072.0-b1"
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

    # VERSION file is wrong upstream, has happened before, so we just overwrite it here.
    version_file = (buildpath/"VERSION")
    rm version_file
    version_file.write version

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
