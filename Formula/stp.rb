class Stp < Formula
  desc "Simple Theorem Prover"
  homepage "https://stp.github.io"

  head "https://github.com/stp/stp.git", :branch => "master"

  stable do
    url "https://github.com/stp/stp/archive/2.3.3.tar.gz"
    sha256 "ea6115c0fc11312c797a4b7c4db8734afcfce4908d078f386616189e01b4fffa"
  end
  bottle do
    cellar :any
    sha256 "4780e20b95c7b0a611964e9b813e810fc5acb9d3d125d7689ceb3ed99515c103" => :catalina
    sha256 "914ae9a184ca80d4e12ca5ff2d485ad6927f603715a8ea37be5491dd5294300d" => :mojave
    sha256 "ff6a784ca1d86f01db0ed305d1dc5da5fe08fca113a70b67adbcbc897cd39d9f" => :high_sierra
  end


  depends_on "bison" => :build  # requires >= 2.6
  depends_on "cmake" => :build
  depends_on "flex" => :build   # requires >= 2.6
  depends_on "minisat"

  def install
    system "cmake", "-DCMAKE_INSTALL_PREFIX=#{prefix}",
                    "-DENABLE_PYTHON_INTERFACE:BOOL=OFF",
                    "."
    system "make"
    system "make", "install"
  end

  test do
    input = <<~EOS
      (set-logic QF_BV)
      (assert (= (bvsdiv (_ bv3 2) (_ bv2 2)) (_ bv0 2)))
      (check-sat)
      (exit)
    EOS

    assert_match(/^sat$/, pipe_output("#{bin}/stp_simple", input, 0))
  end
end
