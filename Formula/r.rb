class R < Formula
  desc "Software environment for statistical computing"
  homepage "https://www.r-project.org/"
  url "https://cran.rstudio.com/src/base/R-3/R-3.4.1.tar.gz"
  sha256 "02b1135d15ea969a3582caeb95594a05e830a6debcdb5b85ed2d5836a6a3fc78"
  revision 2

  bottle do
    sha256 "caa4bf2108cc357ce92efb6e01d62341cb28f124c6bcfe3e9b7128e566114d1c" => :sierra
    sha256 "726e95478c35aae285ce87af86d6be2ab0974c240e37368c037992bf721fb1e3" => :el_capitan
    sha256 "e3b0d80b144b314ea45dbba4e00a531a51629d01bf99758d7aa3bf39e7f691d4" => :yosemite
  end

  depends_on "pkg-config" => :build
  depends_on "gettext"
  depends_on "jpeg"
  depends_on "libpng"
  depends_on "pcre"
  depends_on "readline"
  depends_on "xz"
  depends_on :fortran
  depends_on "openblas" => :optional
  depends_on :java => :optional

  # needed to preserve executable permissions on files without shebangs
  skip_clean "lib/R/bin"

  def install
    # Fix dyld: lazy symbol binding failed: Symbol not found: _clock_gettime
    if MacOS.version == "10.11" && MacOS::Xcode.installed? &&
       MacOS::Xcode.version >= "8.0"
      ENV["ac_cv_have_decl_clock_gettime"] = "no"
    end

    args = [
      "--prefix=#{prefix}",
      "--enable-memory-profiling",
      "--enable-R-framework=#{frameworks}",
      "--without-cairo",
      "--without-x",
      "--with-aqua",
      "--with-lapack",
      "--enable-R-shlib",
      "SED=/usr/bin/sed", # don't remember Homebrew's sed shim
    ]

    if build.with? "openblas"
      args << "--with-blas=-L#{Formula["openblas"].opt_lib} -lopenblas"
      ENV.append "LDFLAGS", "-L#{Formula["openblas"].opt_lib}"
    else
      args << "--with-blas=-framework Accelerate"
      ENV.append_to_cflags "-D__ACCELERATE__" if ENV.compiler != :clang
    end

    if build.with? "java"
      args << "--enable-java"
    else
      args << "--disable-java"
    end

    # Help CRAN packages find gettext and readline
    ["gettext", "readline"].each do |f|
      ENV.append "CPPFLAGS", "-I#{Formula[f].opt_include}"
      ENV.append "LDFLAGS", "-L#{Formula[f].opt_lib}"
    end

    system "./configure", *args
    system "make"
    ENV.deparallelize do
      system "make", "install"
    end

    cd "src/nmath/standalone" do
      system "make"
      ENV.deparallelize do
        system "make", "install"
      end
    end

    r_home = frameworks/"R.framework/Resources"

    # make Homebrew packages discoverable for R CMD INSTALL
    inreplace r_home/"etc/Makeconf" do |s|
      s.gsub!(/^CPPFLAGS =.*/, "\\0 -I#{HOMEBREW_PREFIX}/include")
      s.gsub!(/^LDFLAGS =.*/, "\\0 -L#{HOMEBREW_PREFIX}/lib")
      s.gsub!(/.LDFLAGS =.*/, "\\0 $(LDFLAGS)")
    end

    bin.install_symlink Dir[r_home/"bin/{R,Rscript}"]
    include.install_symlink Dir[r_home/"include/*"]
    lib.install_symlink Dir[r_home/"lib/*"]
    (lib/"pkgconfig").install_symlink frameworks/"lib/pkgconfig/libR.pc"
    man1.install_symlink Dir[r_home/"man1/*"]
  end

  def post_install
    ENV.delete "R_HOME" # Rscript prints garbage if R_HOME is set
    short_version = `#{bin}/Rscript -e 'cat(as.character(getRversion()[1,1:2]))'`.strip
    site_library = HOMEBREW_PREFIX/"lib/R/#{short_version}/site-library"
    site_library_cellar = frameworks/"R.framework/Resources/site-library"
    site_library.mkpath
    site_library_cellar.unlink if site_library_cellar.exist? # Avoid conflict when revision up
    ln_s site_library, site_library_cellar
  end

  test do
    assert_equal "[1] 2", shell_output("#{bin}/Rscript -e 'print(1+1)'").chomp
    assert_equal ".dylib", shell_output("#{bin}/R CMD config DYLIB_EXT").chomp
  end
end
