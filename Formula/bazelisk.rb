class Bazelisk < Formula
  desc "User-friendly launcher for Bazel"
  homepage "https://github.com/bazelbuild/bazelisk/"
  url "https://github.com/bazelbuild/bazelisk.git",
      :tag      => "v1.3.0",
      :revision => "24b8784d71096f3dfa38d6533a770f45a49cda43"
  head "https://github.com/bazelbuild/bazelisk.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "cd510b727fea39be403be09808e2023ff7050c3c610cebe1fc1aacffe73c0f9a" => :catalina
    sha256 "cd510b727fea39be403be09808e2023ff7050c3c610cebe1fc1aacffe73c0f9a" => :mojave
    sha256 "cd510b727fea39be403be09808e2023ff7050c3c610cebe1fc1aacffe73c0f9a" => :high_sierra
  end

  depends_on "bazel" => :build

  def install
    rm_f ".bazelversion" # Homebrew uses the latest bazel
    system "bazel", "build", "--config=release", "//:bazelisk-darwin"

    bin.install "bazel-bin/bazelisk-darwin_amd64" => "bazelisk"
  end

  test do
    ENV["USE_BAZEL_VERSION"] = Formula["bazel"].version
    assert_match /v#{version}/, shell_output("#{bin}/bazelisk version")

    # This is an older than current version, so that we can test that bazelisk
    # will target an explicit version we specify. This version shouldn't need to
    # be bumped.
    ENV["USE_BAZEL_VERSION"] = "0.28.0"
    assert_match /Build label: 0.28.0/, shell_output("#{bin}/bazelisk version")
  end
end
