class Pyqt < Formula
  desc "Python bindings for v5 of Qt"
  homepage "https://www.riverbankcomputing.com/software/pyqt/download5"
  url "https://dl.bintray.com/homebrew/mirror/pyqt-5.10.1.tar.gz"
  url "https://www.riverbankcomputing.com/static/Downloads/PyQt5/5.13.2/PyQt5-5.13.2.tar.gz"
  sha256 "adc17c077bf233987b8e43ada87d1e0deca9bd71a13e5fd5fc377482ed69c827"

  bottle do
    cellar :any
    sha256 "2e2535d179edae8c6097337432c8f7f4b3ef674fde3bb44cf1ef2545f28b296d" => :mojave
    sha256 "814c28f94e026eb94186b787a45cf1e82f59f1d9ba15c70c0950f5c70cf894d1" => :high_sierra
    sha256 "e225e01bcf22a4246548148b102c7cef0aaa9ffd9e8ac7f6419b7b964baf25db" => :sierra
  end

  depends_on "python"
  depends_on "qt"
  depends_on "sip"

  def install
    version = Language::Python.major_minor_version "python3"
    args = ["--confirm-license",
            "--bindir=#{bin}",
            "--destdir=#{lib}/python#{version}/site-packages",
            "--stubsdir=#{lib}/python#{version}/site-packages/PyQt5",
            "--sipdir=#{share}/sip/Qt5",
            # sip.h could not be found automatically
            "--sip-incdir=#{Formula["sip"].opt_include}",
            "--qmake=#{Formula["qt"].bin}/qmake",
            # Force deployment target to avoid libc++ issues
            "QMAKE_MACOSX_DEPLOYMENT_TARGET=#{MacOS.version}",
            "--qml-plugindir=#{pkgshare}/plugins",
            "--verbose"]

    system "python3", "configure.py", *args
    system "make"
    system "make", "install"
    system "make", "clean"
  end

  test do
    system "#{bin}/pyuic5", "--version"
    system "#{bin}/pylupdate5", "-version"

    system "python3", "-c", "import PyQt5"
    %w[
      Gui
      Location
      Multimedia
      Network
      Quick
      Svg
      WebEngineWidgets
      Widgets
      Xml
    ].each { |mod| system "python3", "-c", "import PyQt5.Qt#{mod}" }
  end
end
