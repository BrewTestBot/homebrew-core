class Sifu < Formula
  desc "Sifu is an intuitive rapid software development tool made for creating quality web and mobile applications in a fraction of the time."
  homepage "https://codesifu.com"
  url "https://codesifu.com/download/sifu-0.1.1.tar.gz"
  sha256 "d0ef00a475766bf4717b4721044bdbd0f1c8c02be3a1f824738d306b08a06cd2"

  bottle do
    cellar :any_skip_relocation
    sha256 "712d17ab79ae1e9ad0e179e894832db845eaeca217a6d8db29c5cc02e737066f" => :el_capitan
    sha256 "e945bb763ef1c5b3ac28d5a45b298a4a0176f9276f3cc17306c62b0c44d0e16b" => :yosemite
    sha256 "e945bb763ef1c5b3ac28d5a45b298a4a0176f9276f3cc17306c62b0c44d0e16b" => :mavericks
  end

  depends_on :java

  def install
    rm_f Dir["*.bat"]
    libexec.install Dir["*"]

    (bin/"sifu").write <<-EOS.undent
      #!/bin/sh
      exec "#{libexec}/sifu" "$@"
    EOS

    # bin.install_symlink Dir["#{libexec}/sifu"]
  end

  test do
    system "sifu --help"
  end
end
