require "language/node"

class FirebaseCli < Formula
  desc "Firebase command-line tools"
  homepage "https://firebase.google.com/docs/cli/"
  url "https://registry.npmjs.org/firebase-tools/-/firebase-tools-7.3.0.tgz"
  sha256 "9d354518bccc0f025fb9fc44c162ebc68fd8a32b62ff25f23cf3ac5ea5bf4cd3"
  head "https://github.com/firebase/firebase-tools.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "c2c1064a99b28ce71d582dcfa70764c21ec9c3a2c73bd48395ada9a42ffa48ed" => :mojave
    sha256 "06638b246150d9104c7767e1e536d4cff2d30e131e1fe176ece1588090d42de2" => :high_sierra
    sha256 "e0c7a8b34bcd81f94121c8fd616e894a5cd279929992cc0c696824fa142cf8f9" => :sierra
  end

  depends_on "node"

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    (testpath/"test.exp").write <<~EOS
      spawn #{bin}/firebase login:ci --no-localhost
      expect "Paste"
    EOS
    assert_match "authorization code", shell_output("expect -f test.exp")
  end
end
