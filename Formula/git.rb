class Git < Formula
  desc "Distributed revision control system"
  homepage "https://git-scm.com"
  url "https://www.kernel.org/pub/software/scm/git/git-2.20.1.tar.xz"
  sha256 "9d2e91e2faa2ea61ba0a70201d023b36f54d846314591a002c610ea2ab81c3e9"
  head "https://github.com/git/git.git", :shallow => false

  bottle do
    rebuild 2
    sha256 "c41bba2442a795c6d94b24565865811826becd7e3dba0226fe0cab0990ee4bef" => :mojave
    sha256 "ecf0d2a4663634c7d29c068040a4ded253d8b5e042a2eb4db005c16d221d8275" => :high_sierra
    sha256 "04b5b0d7bed4a7d2a952f7afbd7df4d93805dd9957047d31344c8bb12d614cc7" => :sierra
  end

  depends_on "gettext"
  depends_on "pcre2"

  if MacOS.version < :yosemite
    depends_on "openssl"
    depends_on "curl"
  else
    deprecated_option "with-brewed-openssl" => "with-openssl"
    deprecated_option "with-brewed-curl" => "with-curl"

    option "with-openssl", "Build with Homebrew's OpenSSL instead of using CommonCrypto"
    option "with-curl", "Use Homebrew's version of cURL library"

    depends_on "openssl" => :optional
    depends_on "curl" => :optional
  end

  resource "html" do
    url "https://www.kernel.org/pub/software/scm/git/git-htmldocs-2.20.1.tar.xz"
    sha256 "18a00408437c6816e7c5396c8b96b38bf022f924852492a73dd3888ad2572ad7"
  end

  resource "man" do
    url "https://www.kernel.org/pub/software/scm/git/git-manpages-2.20.1.tar.xz"
    sha256 "060acce347cfb712d0c7dfe7578c5291fde2d3d807917b2828c8aae3c90876ba"
  end

  resource "Net::SMTP::SSL" do
    url "https://cpan.metacpan.org/authors/id/R/RJ/RJBS/Net-SMTP-SSL-1.04.tar.gz"
    sha256 "7b29c45add19d3d5084b751f7ba89a8e40479a446ce21cfd9cc741e558332a00"
  end

  def install
    # If these things are installed, tell Git build system not to use them
    ENV["NO_FINK"] = "1"
    ENV["NO_DARWIN_PORTS"] = "1"
    ENV["NO_R_TO_GCC_LINKER"] = "1" # pass arguments to LD correctly
    ENV["PYTHON_PATH"] = which("python")
    ENV["PERL_PATH"] = which("perl")
    ENV["USE_LIBPCRE2"] = "1"
    ENV["INSTALL_SYMLINKS"] = "1"
    ENV["LIBPCREDIR"] = Formula["pcre2"].opt_prefix
    ENV["V"] = "1" # build verbosely

    perl_version = Utils.popen_read("perl --version")[/v(\d+\.\d+)(?:\.\d+)?/, 1]

    if MacOS.version >= :mavericks
      ENV["PERLLIB_EXTRA"] = %W[
        #{MacOS.active_developer_dir}
        /Library/Developer/CommandLineTools
        /Applications/Xcode.app/Contents/Developer
      ].uniq.map do |p|
        "#{p}/Library/Perl/#{perl_version}/darwin-thread-multi-2level"
      end.join(":")
    end

    unless quiet_system ENV["PERL_PATH"], "-e", "use ExtUtils::MakeMaker"
      ENV["NO_PERL_MAKEMAKER"] = "1"
    end

    args = %W[
      prefix=#{prefix}
      sysconfdir=#{etc}
      CC=#{ENV.cc}
      CFLAGS=#{ENV.cflags}
      LDFLAGS=#{ENV.ldflags}
    ]

    if build.with?("openssl") || MacOS.version < :yosemite
      openssl_prefix = Formula["openssl"].opt_prefix
      args += %W[NO_APPLE_COMMON_CRYPTO=1 OPENSSLDIR=#{openssl_prefix}]
    else
      args += %w[NO_OPENSSL=1 APPLE_COMMON_CRYPTO=1]
    end

    system "make", "install", *args

    git_core = libexec/"git-core"

    # Install the macOS keychain credential helper
    cd "contrib/credential/osxkeychain" do
      system "make", "CC=#{ENV.cc}",
                     "CFLAGS=#{ENV.cflags}",
                     "LDFLAGS=#{ENV.ldflags}"
      git_core.install "git-credential-osxkeychain"
      system "make", "clean"
    end

    # Generate diff-highlight perl script executable
    cd "contrib/diff-highlight" do
      system "make"
    end

    # Install the netrc credential helper
    cd "contrib/credential/netrc" do
      system "make", "test"
      git_core.install "git-credential-netrc"
    end

    # Install git-subtree
    cd "contrib/subtree" do
      system "make", "CC=#{ENV.cc}",
                     "CFLAGS=#{ENV.cflags}",
                     "LDFLAGS=#{ENV.ldflags}"
      git_core.install "git-subtree"
    end

    # install the completion script first because it is inside "contrib"
    bash_completion.install "contrib/completion/git-completion.bash"
    bash_completion.install "contrib/completion/git-prompt.sh"
    zsh_completion.install "contrib/completion/git-completion.zsh" => "_git"
    cp "#{bash_completion}/git-completion.bash", zsh_completion

    elisp.install Dir["contrib/emacs/*.el"]
    (share/"git-core").install "contrib"

    # We could build the manpages ourselves, but the build process depends
    # on many other packages, and is somewhat crazy, this way is easier.
    man.install resource("man")
    (share/"doc/git-doc").install resource("html")

    # Make html docs world-readable
    chmod 0644, Dir["#{share}/doc/git-doc/**/*.{html,txt}"]
    chmod 0755, Dir["#{share}/doc/git-doc/{RelNotes,howto,technical}"]

    # To avoid this feature hooking into the system OpenSSL, remove it.
    # If you need it, install git --with-openssl.
    if MacOS.version >= :yosemite && build.without?("openssl")
      rm "#{libexec}/git-core/git-imap-send"
    end

    # git-send-email needs Net::SMTP::SSL
    resource("Net::SMTP::SSL").stage do
      (share/"perl5").install "lib/Net"
    end

    # This is only created when building against system Perl, but it isn't
    # purged by Homebrew's post-install cleaner because that doesn't check
    # "Library" directories. It is however pointless to keep around as it
    # only contains the perllocal.pod installation file.
    rm_rf prefix/"Library/Perl"

    # Set the macOS keychain credential helper by default
    # (as Apple's CLT's git also does this).
    (buildpath/"gitconfig").write <<~EOS
      [credential]
      \thelper = osxkeychain
    EOS
    etc.install "gitconfig"
  end

  test do
    system bin/"git", "init"
    %w[haunted house].each { |f| touch testpath/f }
    system bin/"git", "add", "haunted", "house"
    system bin/"git", "commit", "-a", "-m", "Initial Commit"
    assert_equal "haunted\nhouse", shell_output("#{bin}/git ls-files").strip

    # Check Net::SMTP::SSL was installed correctly.
    %w[foo bar].each { |f| touch testpath/f }
    system bin/"git", "add", "foo", "bar"
    system bin/"git", "commit", "-a", "-m", "Second Commit"
    assert_match "Authentication Required", shell_output(
      "#{bin}/git send-email --to=dev@null.com --smtp-server=smtp.gmail.com " \
      "--smtp-encryption=tls --confirm=never HEAD^ 2>&1", 255
    )
  end
end
