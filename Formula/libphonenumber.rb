class Libphonenumber < Formula
  desc "C++ Phone Number library by Google"
  homepage "https://github.com/googlei18n/libphonenumber"
  url "https://github.com/googlei18n/libphonenumber/archive/libphonenumber-7.7.1.tar.gz"
  sha256 "5c964d4c86fbcebb5a06858647f36cd5c537e2f198d4e30ea29b8cce40d80668"
  revision 1

  bottle do
    cellar :any
    sha256 "5b0d12e08e45e69110a02b7f68eeb04ce5698cc281dc07ce8ca9dfe28085b26c" => :sierra
    sha256 "ce5534dccc2573244e6e66510f3450e08b520a3d4e41bb2fb094071184925824" => :el_capitan
    sha256 "b84c2ca68825ffc5f2cd53916f68397442ae068bfbee893adb893665caa78f66" => :yosemite
  end

  depends_on "cmake" => :build
  depends_on :java => "1.7+"
  depends_on "icu4c"
  depends_on "protobuf"
  depends_on "boost@1.61"
  depends_on "re2"

  resource "gtest" do
    url "https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/googletest/gtest-1.7.0.zip"
    sha256 "247ca18dd83f53deb1328be17e4b1be31514cedfc1e3424f672bf11fd7e0d60d"
  end

  def install
    (buildpath/"gtest").install resource("gtest")

    cd "gtest" do
      system "cmake", ".", *std_cmake_args
      system "make"
    end

    args = std_cmake_args + %W[
      -DGTEST_INCLUDE_DIR:PATH=#{buildpath}/gtest/include
      -DGTEST_LIB:PATH=#{buildpath}/gtest/libgtest.a
      -DGTEST_SOURCE_DIR:PATH=#{buildpath}/gtest/src
    ]

    system "cmake", "cpp", *args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<-EOS.undent
      #include <phonenumbers/phonenumberutil.h>
      #include <phonenumbers/phonenumber.pb.h>
      #include <iostream>
      #include <string>

      using namespace i18n::phonenumbers;

      int main() {
        PhoneNumberUtil *phone_util_ = PhoneNumberUtil::GetInstance();
        PhoneNumber test_number;
        string formatted_number;
        test_number.set_country_code(1);
        test_number.set_national_number(6502530000ULL);
        phone_util_->Format(test_number, PhoneNumberUtil::E164, &formatted_number);
        if (formatted_number == "+16502530000") {
          return 0;
        } else {
          return 1;
        }
      }
    EOS
    system ENV.cxx, "test.cpp", "-L#{lib}", "-lphonenumber", "-o", "test"
    system "./test"
  end
end
