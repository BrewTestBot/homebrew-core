class Treefrog < Formula
  desc "High-speed C++ MVC Framework for Web Application"
  homepage "http://www.treefrogframework.org/"
  url "https://github.com/treefrogframework/treefrog-framework/archive/v1.14.0.tar.gz"
  sha256 "d3208baed1aabea4ac47a54d74dc6c3536b7138c6b9c12613219421df5b6c7f5"
  head "https://github.com/treefrogframework/treefrog-framework.git", :branch => "master"

  bottle do
    rebuild 1
    sha256 "a92246b2002c9aa308bc753085107a0da95ea1f9ad91c26d0f628e22be9a6500" => :sierra
    sha256 "a92246b2002c9aa308bc753085107a0da95ea1f9ad91c26d0f628e22be9a6500" => :el_capitan
  end

  option "with-mysql", "enable --with-mysql option for Qt build"
  option "with-postgresql", "enable --with-postgresql option for Qt build"
  option "with-qt5", "build and link with QtGui module"

  depends_on :macos => :el_capitan
  depends_on :xcode => [:build, "8.0"]

  qt5_build_options = []
  qt5_build_options << "with-mysql" if build.with?("mysql")
  qt5_build_options << "with-postgresql" if build.with?("postgresql")
  depends_on "qt5" => qt5_build_options

  def install
    args = ["--prefix=#{prefix}"]
    args << "--enable-gui-mod" if build.with? "qt5"

    system "./configure", *args

    cd "src" do
      system "make"
      system "make", "install"
    end

    cd "tools" do
      system "make"
      system "make", "install"
    end
  end

  test do
    system bin/"tspawn", "new", "hello"
    assert File.exist?("hello")
    cd "hello" do
      assert File.exist?("hello.pro")
      system HOMEBREW_PREFIX/"opt/qt5/bin/qmake"
      assert File.exist?("Makefile")
      system "make"
      system bin/"treefrog", "-v"
    end
  end
end
