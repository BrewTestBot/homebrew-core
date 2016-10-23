require "language/go"

class Aurora < Formula
  desc "Beanstalk queue server console"
  homepage "https://xuri.me/aurora"
  url "https://github.com/Luxurioust/aurora/archive/1.2.tar.gz"
  sha256 "ef952527b7f3c2475dd17622aea749e727f43f7098ae20b1a9ad314b1a7293da"

  depends_on "go" => :build

  go_resource "github.com/BurntSushi/toml" do
    url "https://github.com/BurntSushi/toml.git",
        :revision => "99064174e013895bbd9b025c31100bd1d9b590ca"
  end

  go_resource "github.com/rakyll/statik" do
    url "https://github.com/rakyll/statik.git",
        :revision => "e383bbf6b2ec1a2fb8492dfd152d945fb88919b6"
  end

  go_resource "github.com/kr/beanstalk" do
    url "https://github.com/kr/beanstalk.git",
        :revision => "e99e1a384e4ace0401329ea37f702a2904990f91"
  end

  def install
    ENV["GOPATH"] = buildpath
    Language::Go.stage_deps resources, buildpath/"src"
    mkdir_p "src/github.com/Luxurioust"
    ln_s buildpath, "src/github.com/Luxurioust/aurora"
    system "go", "build", "-o", bin/"aurora"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/aurora -v")
  end
end
