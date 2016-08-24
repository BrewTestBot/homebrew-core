class Leiningen < Formula
  desc "Build tool for Clojure"
  homepage "https://github.com/technomancy/leiningen"
  url "https://github.com/technomancy/leiningen/archive/2.7.0.tar.gz"
  sha256 "db2069e9a87c72c7f83934e3068dc4b28c688115f7869056c4150392abc54c3d"
  head "https://github.com/technomancy/leiningen.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "b3797e0c27675a8cc668be08f2205a44040be57e4b0c8d2a2b817df8789f8745" => :el_capitan
    sha256 "6bd2b13f7bef3d2cc37a0079bc6eed62097f2229fe06836506eb4230868b698d" => :yosemite
    sha256 "341eedf47e78589d201f6d6f95fcf2e60e3e47ac914a4bea35c573f58fd103dd" => :mavericks
  end

  resource "jar" do
    url "https://github.com/technomancy/leiningen/releases/download/2.7.0/leiningen-2.7.0-standalone.zip", :using => :nounzip
    sha256 "b0a53fd9fa73e9d87c04ef25ba1ca174b0c062b803108648d7157176ccde7435"
  end

  def install
    jar = "leiningen-#{version}-standalone.jar"
    resource("jar").stage do
      libexec.install "leiningen-#{version}-standalone.zip" => jar
    end

    # bin/lein autoinstalls and autoupdates, which doesn't work too well for us
    inreplace "bin/lein-pkg" do |s|
      s.change_make_var! "LEIN_JAR", libexec/jar
    end

    bin.install "bin/lein-pkg" => "lein"
    bash_completion.install "bash_completion.bash" => "lein-completion.bash"
    zsh_completion.install "zsh_completion.zsh" => "_lein"
  end

  def caveats; <<-EOS.undent
    Dependencies will be installed to:
      $HOME/.m2/repository
    To play around with Clojure run `lein repl` or `lein help`.
    EOS
  end

  test do
    ENV.java_cache

    (testpath/"project.clj").write <<-EOS.undent
      (defproject brew-test "1.0"
        :dependencies [[org.clojure/clojure "1.5.1"]])
    EOS
    (testpath/"src/brew_test/core.clj").write <<-EOS.undent
      (ns brew-test.core)
      (defn adds-two
        "I add two to a number"
        [x]
        (+ x 2))
    EOS
    (testpath/"test/brew_test/core_test.clj").write <<-EOS.undent
      (ns brew-test.core-test
        (:require [clojure.test :refer :all]
                  [brew-test.core :as t]))
      (deftest canary-test
        (testing "adds-two yields 4 for input of 2"
          (is (= 4 (t/adds-two 2)))))
    EOS
    system "#{bin}/lein", "test"
  end
end
