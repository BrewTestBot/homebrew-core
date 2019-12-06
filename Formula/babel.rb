require "language/node"
require "json"

class Babel < Formula
  desc "Compiler for writing next generation JavaScript"
  homepage "https://babeljs.io/"
  url "https://registry.npmjs.org/@babel/core/-/core-7.7.5.tgz"
  sha256 "9ee6e7a5d8ad04321b9ae60fdad4a25023e0653876c32bfbe53277daf1f4d0d2"

  bottle do
    sha256 "0f17ef20a93d927fd499e56bbf80952348a0648bd13c0daff7b48a9c38145dc7" => :catalina
    sha256 "83a2fff8d5318875ae2f7152a18ebc2350651c7ed4e88fa53065f004b1f4d715" => :mojave
    sha256 "20579144803ca5296abb313f7438c97a87bb229aa494e4f8c6bf9ade5bb5addf" => :high_sierra
  end

  depends_on "node"

  resource "babel-cli" do
    url "https://registry.npmjs.org/@babel/cli/-/cli-7.7.5.tgz"
    sha256 "9a9805fccbc240dcbb47f1348f7f313ebf1b9bef28e671c2c71d93cb1f9948c4"
  end

  def install
    (buildpath/"node_modules/@babel/core").install Dir["*"]
    buildpath.install resource("babel-cli")

    # declare babel-core as a bundledDependency of babel-cli
    pkg_json = JSON.parse(IO.read("package.json"))
    pkg_json["dependencies"]["@babel/core"] = version
    pkg_json["bundledDependencies"] = ["@babel/core"]
    IO.write("package.json", JSON.pretty_generate(pkg_json))

    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    (testpath/"script.js").write <<~EOS
      [1,2,3].map(n => n + 1);
    EOS

    system bin/"babel", "script.js", "--out-file", "script-compiled.js"
    assert_predicate testpath/"script-compiled.js", :exist?, "script-compiled.js was not generated"
  end
end
