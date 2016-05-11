require "language/go"

class GitGitlab < Formula
  desc "Git CLI support for GitLab"
  homepage "https://github.com/numa08/git-gitlab"
  url "https://github.com/numa08/git-gitlab/archive/9a1a74a7609178f25afc1786e01c2375762de48c.tar.gz"
  version "0.1.0"
  sha256 "3cb01102d8dcf523fa5c276719d386bc830c2d9050bfaa3911e166276f623783"

  bottle do
    sha256 "b1ac50005b351807660cf9e9e52f53d8aff3f1ae8a1c8efc4bc75116763fd9ff" => :el_capitan
    sha256 "df6a6ce7998a04909bbc6abbe8727bc2351eecb3ab3d42b069fd504d9eb8e7f6" => :yosemite
    sha256 "d0ccff4cd9233f7554314585be63bcf8848ce11aaf0650c35f9f8d468bd2de69" => :mavericks
  end

  depends_on "libgit2" => :build
  depends_on "pkg-config" => :build
  depends_on "go" => :build

  go_resource "gopkg.in/libgit2/git2go.v23" do
    url "https://gopkg.in/libgit2/git2go.v23.git",
      :revision => "fa644d2fc9efa3baee93b525212d76dfa17a5db5"
  end

  go_resource "github.com/plouc/go-gitlab-client" do
    url "https://github.com/plouc/go-gitlab-client.git",
      :revision => "a526ef09e9e03f673a43ecd4a687abf6c25343ca"
  end

  go_resource "github.com/codegangsta/cli" do
    url "https://github.com/codegangsta/cli.git",
      :revision => "f7b459e3463391ed8bd9cf1515d0d27ccf835efb"
  end

  def install
    ENV["GOBIN"] = bin
    ENV["GOPATH"] = buildpath
    ENV["GOHOME"] = buildpath

    mkdir_p buildpath/"src/github.com/numa08/"
    ln_sf buildpath, buildpath/"src/github.com/numa08/git-gitlab"
    Language::Go.stage_deps resources, buildpath/"src"

    system "go", "build", "-o", bin/"git-lab"
    man1.install "man/git-lab.1"
  end

  test do
    system bin/"git-lab", "-h"
  end
end
