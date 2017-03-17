class Rust < Formula
  desc "Safe, concurrent, practical language"
  homepage "https://www.rust-lang.org/"

  stable do
    url "https://static.rust-lang.org/dist/rustc-1.16.0-src.tar.gz"
    sha256 "f966b31eb1cd9bd2df817c391a338eeb5b9253ae0a19bf8a11960c560f96e8b4"

    resource "cargo" do
      url "https://github.com/rust-lang/cargo.git",
          :tag => "0.17.0",
          :revision => "f9e54817e53c7b9845cc7c1ede4c11e4d3e42e36"
    end

    resource "racer" do
      url "https://github.com/phildawes/racer/archive/2.0.6.tar.gz"
      sha256 "a9704478f72037e76d4d3702fe39b3c50597bde35dac1a11bf8034de87bbdc70"
    end
  end

  bottle do
    sha256 "a668d0c7892dfc0fcf19c9293d8094178e0eb2f1923a98afc150abf157026978" => :sierra
    sha256 "05a8050aa155339b1bb123763cfde37321cc540ba441962e9ac3fb9698770837" => :el_capitan
    sha256 "3d58445118ec95a4de71ec5a0cee5679ef393b138dad75c266d013ee805c5c59" => :yosemite
  end

  head do
    url "https://github.com/rust-lang/rust.git"

    resource "cargo" do
      url "https://github.com/rust-lang/cargo.git"
    end
  end

  option "with-llvm", "Build with brewed LLVM. By default, Rust's LLVM will be used."
  option "with-racer", "Build Racer code completion tool, and retain Rust sources."

  depends_on "cmake" => :build
  depends_on "pkg-config" => :run
  depends_on "llvm" => :optional
  depends_on "openssl"
  depends_on "libssh2"

  conflicts_with "multirust", :because => "both install rustc, rustdoc, cargo, rust-lldb, rust-gdb"

  # According to the official readme, GCC 4.7+ is required
  fails_with :gcc_4_0
  fails_with :gcc
  ("4.3".."4.6").each do |n|
    fails_with :gcc => n
  end

  resource "cargobootstrap" do
    # From https://github.com/rust-lang/rust/blob/#{version}/src/stage0.txt
    url "https://s3.amazonaws.com/rust-lang-ci/cargo-builds/6e0c18cccc8b0c06fba8a8d76486f81a792fb420/cargo-nightly-x86_64-apple-darwin.tar.gz"
    # From name=cargo-nightly-x86_64-apple-darwin; tar -xf $name.tar.gz $name/version; cat $name/version
    version "2017-01-27"
    sha256 "0a6b78b8c6344e7a14f1aa57ebfa0154d4ea560332833846dbeaa3a6772a010a"
  end

  def install
    args = ["--prefix=#{prefix}"]
    args << "--disable-rpath" if build.head?
    args << "--enable-clang" if ENV.compiler == :clang
    args << "--llvm-root=#{Formula["llvm"].opt_prefix}" if build.with? "llvm"
    if build.head?
      args << "--release-channel=nightly"
    else
      args << "--release-channel=stable"
    end
    system "./configure", *args
    system "make"
    system "make", "install"

    resource("cargobootstrap").stage do
      system "./install.sh", "--prefix=#{buildpath}/cargobootstrap"
    end
    ENV.prepend_path "PATH", buildpath/"cargobootstrap/bin"

    resource("cargo").stage do
      system "./configure", "--prefix=#{prefix}", "--local-rust-root=#{prefix}",
                            "--enable-optimize"
      system "make"
      system "make", "install"
    end

    if build.with? "racer"
      resource("racer").stage do
        ENV.prepend_path "PATH", bin
        cargo_home = buildpath/"cargo_home"
        cargo_home.mkpath
        ENV["CARGO_HOME"] = cargo_home
        system bin/"cargo", "build", "--release", "--verbose"
        (libexec/"bin").install "target/release/racer"
        (bin/"racer").write_env_script(libexec/"bin/racer", :RUST_SRC_PATH => pkgshare/"rust_src")
      end
      # Remove any binary files; as Homebrew will run ranlib on them and barf.
      rm_rf Dir["src/{llvm,test,librustdoc,etc/snapshot.pyc}"]
      (pkgshare/"rust_src").install Dir["src/*"]
    end

    rm_rf prefix/"lib/rustlib/uninstall.sh"
    rm_rf prefix/"lib/rustlib/install.log"
  end

  test do
    system "#{bin}/rustdoc", "-h"
    (testpath/"hello.rs").write <<-EOS.undent
    fn main() {
      println!("Hello World!");
    }
    EOS
    system "#{bin}/rustc", "hello.rs"
    assert_equal "Hello World!\n", `./hello`
    system "#{bin}/cargo", "new", "hello_world", "--bin"
    assert_equal "Hello, world!",
                 (testpath/"hello_world").cd { `#{bin}/cargo run`.split("\n").last }
  end
end
