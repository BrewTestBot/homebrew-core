class Gecode < Formula
  desc "Toolkit for developing constraint-based systems and applications"
  homepage "http://www.gecode.org/"
  url "http://www.gecode.org/download/gecode-5.1.0.tar.gz"
  sha256 "f9885f97e0f80b54eaf1a8f9d0c419d831229a689619f6429c6148f5c50740d0"

  bottle do
    cellar :any
    rebuild 1
    sha256 "03268b2467a7c91378e2dc6f457887692c005b630c0073055532e9e498da1f61" => :sierra
    sha256 "70893225faa62c8e6f6820a82c6ca90a527b93ccad4ed4d0c83a5ed1dce75fcd" => :el_capitan
    sha256 "d144849bd4886dd350c134365bde83081b2b42f5b3089693372f9febfc871e51" => :yosemite
  end

  deprecated_option "with-qt5" => "with-qt"

  depends_on "qt" => :optional

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-examples
    ]
    ENV.cxx11
    if build.with? "qt"
      args << "--enable-qt"
      ENV.append_path "PKG_CONFIG_PATH", "#{HOMEBREW_PREFIX}/opt/qt/lib/pkgconfig"
    else
      args << "--disable-qt"
    end
    system "./configure", *args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<-EOS.undent
      #include <gecode/driver.hh>
      #include <gecode/int.hh>
      #if defined(GECODE_HAS_QT) && defined(GECODE_HAS_GIST)
      #include <QtGui/QtGui>
      #if QT_VERSION >= 0x050000
      #include <QtWidgets/QtWidgets>
      #endif
      #endif
      using namespace Gecode;
      class Test : public Script {
      public:
        IntVarArray v;
        Test(const Options& o) : Script(o) {
          v = IntVarArray(*this, 10, 0, 10);
          distinct(*this, v);
          branch(*this, v, INT_VAR_NONE(), INT_VAL_MIN());
        }
        Test(bool share, Test& s) : Script(share, s) {
          v.update(*this, share, s.v);
        }
        virtual Space* copy(bool share) {
          return new Test(share, *this);
        }
        virtual void print(std::ostream& os) const {
          os << v << std::endl;
        }
      };
      int main(int argc, char* argv[]) {
        Options opt("Test");
        opt.iterations(500);
      #if defined(GECODE_HAS_QT) && defined(GECODE_HAS_GIST)
        Gist::Print<Test> p("Print solution");
        opt.inspect.click(&p);
      #endif
        opt.parse(argc, argv);
        Script::run<Test, DFS, Options>(opt);
        return 0;
      }
    EOS

    args = %W[
      -std=c++11
      -I#{HOMEBREW_PREFIX}/opt/qt/include
      -I#{include}
      -lgecodedriver
      -lgecodesearch
      -lgecodeint
      -lgecodekernel
      -lgecodesupport
      -L#{lib}
      -o test
    ]
    args << "-lgecodegist" if build.with? "qt"
    system ENV.cxx, "test.cpp", *args
    assert_match "{0, 1, 2, 3, 4, 5, 6, 7, 8, 9}", shell_output("./test")
  end
end
