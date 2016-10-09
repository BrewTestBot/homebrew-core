class Bazel < Formula
  desc "Google's own build tool"
  homepage "https://www.bazel.io/"
  url "https://github.com/bazelbuild/bazel/archive/0.3.2.tar.gz"
  sha256 "9692ac3318a40e8a0530f68bbfc473ae5f6a4a5c0fe08d2f88612ca4d40ba54a"
  head "https://github.com/bazelbuild/bazel.git"

  bottle do
    cellar :any_skip_relocation
    rebuild 1
    sha256 "e248c283f389225b1105a78521c611c8a3b4ef260e08f378b84b65f43f05d5d4" => :sierra
    sha256 "2b203c341f67e2baed45a89d4e0c250952df2ef6d95086d6fdf89c71f6e23309" => :el_capitan
    sha256 "5a13282d2f9c4224be116e07bbee817d6f7ba4abaa6addc168b796ad1ccc92ea" => :yosemite
  end

  depends_on :java => "1.8+"
  depends_on :macos => :yosemite

  def install
    ENV["EMBED_LABEL"] = "#{version}-homebrew"
    # Force Bazel ./compile.sh to put its temporary files in the buildpath
    ENV["BAZEL_WRKDIR"] = buildpath/"work"

    system "./compile.sh"
    system "./output/bazel", "--output_user_root", buildpath/"output_user_root",
           "build", "scripts:bash_completion"

    bin.install "scripts/packages/bazel.sh" => "bazel"
    bin.install "output/bazel" => "bazel-real"
    bash_completion.install "bazel-bin/scripts/bazel-complete.bash"
    zsh_completion.install "scripts/zsh_completion/_bazel"
  end

  test do
    touch testpath/"WORKSPACE"

    (testpath/"ProjectRunner.java").write <<-EOS.undent
      public class ProjectRunner {
        public static void main(String args[]) {
          System.out.println("Hi!");
        }
      }
    EOS

    (testpath/"BUILD").write <<-EOS.undent
      java_binary(
        name = "bazel-test",
        srcs = glob(["*.java"]),
        main_class = "ProjectRunner",
      )
    EOS

    system bin/"bazel", "build", "//:bazel-test"
    system "bazel-bin/bazel-test"
  end
end
