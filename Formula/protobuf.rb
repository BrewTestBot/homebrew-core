class Protobuf < Formula
  desc "Protocol buffers (Google's data interchange format)"
  homepage "https://github.com/protocolbuffers/protobuf/"
  url "https://github.com/protocolbuffers/protobuf.git",
      :tag      => "v3.9.1",
      :revision => "655310ca192a6e3a050e0ca0b7084a2968072260"
  head "https://github.com/protocolbuffers/protobuf.git"

  bottle do
    cellar :any
    sha256 "37ae3bf6fb681f932fc55a27dfedced7fe3d10baaaadfd07d60299c0804ba461" => :mojave
    sha256 "6c8b3ffb85dbca3383b48b23dea4e44e05e8157168260d293e62d2a5dcbed020" => :high_sierra
    sha256 "a4f2a148c06cba60a078c9283783210ea4c4be854ed02df2a600899f82f9c323" => :sierra
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "python" => [:build, :test]
  depends_on "python@2" => [:build, :test]

  resource "six" do
    url "https://files.pythonhosted.org/packages/dd/bf/4138e7bfb757de47d1f4b6994648ec67a51efe58fa907c1e11e350cddfca/six-1.12.0.tar.gz"
    sha256 "d16a0141ec1a18405cd4ce8b4613101da75da0e9a7aec5bdd4fa804d0e0eba73"
  end

  def install
    # Don't build in debug mode. See:
    # https://github.com/Homebrew/homebrew/issues/9279
    # https://github.com/protocolbuffers/protobuf/blob/5c24564811c08772d090305be36fae82d8f12bbe/configure.ac#L61
    ENV.prepend "CXXFLAGS", "-DNDEBUG"
    ENV.cxx11

    system "./autogen.sh"
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}", "--with-zlib"
    system "make"
    system "make", "check"
    system "make", "install"

    # Install editor support and examples
    doc.install "editors", "examples"

    ENV.append_to_cflags "-I#{include}"
    ENV.append_to_cflags "-L#{lib}"

    ["python2", "python3"].each do |python|
      resource("six").stage do
        system python, *Language::Python.setup_install_args(libexec)
      end
      chdir "python" do
        system python, *Language::Python.setup_install_args(libexec),
                       "--cpp_implementation"
      end

      version = Language::Python.major_minor_version python
      site_packages = "lib/python#{version}/site-packages"
      pth_contents = "import site; site.addsitedir('#{libexec/site_packages}')\n"
      (prefix/site_packages/"homebrew-protobuf.pth").write pth_contents
    end
  end

  test do
    testdata = <<~EOS
      syntax = "proto3";
      package test;
      message TestCase {
        string name = 4;
      }
      message Test {
        repeated TestCase case = 1;
      }
    EOS
    (testpath/"test.proto").write testdata
    system bin/"protoc", "test.proto", "--cpp_out=."
    system "python2.7", "-c", "import google.protobuf"
    system "python3", "-c", "import google.protobuf"
  end
end
