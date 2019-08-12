class Drafter < Formula
  desc "Native C/C++ API Blueprint Parser"
  homepage "https://apiblueprint.org/"
  url "https://github.com/apiaryio/drafter/releases/download/v4.0.0/drafter-4.0.0.tar.gz"
  sha256 "f284cddf24c321947f85c21e5b27500e876f0181d91eda7d96b3350b48533139"
  head "https://github.com/apiaryio/drafter.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "886a7b2595eebd07cee223f5d5a53a4748e91719c7f4f3a37c236c8476b3c532" => :mojave
    sha256 "5d350d1a7fb4aa5e9561933f0e9638ee59fd93b0d9168d07e665a806e472d5f1" => :high_sierra
    sha256 "a90e9d4493f252d29d69e186dcc49eb116f6bc506d07769f03864f56d5840f08" => :sierra
    sha256 "dc86d4e8dc44c2dead52e57c3bf6403d691926b9abf274f16b94c9649dd562fd" => :el_capitan
  end

  depends_on "cmake" => :build

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "drafter", "drafter-cli"
    system "make", "install"
  end

  test do
    (testpath/"api.apib").write <<~EOS
      # Homebrew API [/brew]

      ## Retrieve All Formula [GET /Formula]
      + Response 200 (application/json)
        + Attributes (array)
    EOS
    assert_equal "OK.", shell_output("#{bin}/drafter -l api.apib 2>&1").strip
  end
end
