class Wdc < Formula
  desc "WebDAV Client provides easy and convenient to work with WebDAV-servers."
  homepage "https://designerror.github.io/webdav-client-cpp"
  url "https://github.com/designerror/webdav-client-cpp/archive/v1.0.0.tar.gz"
  sha256 "649a75a7fe3219dff014bf8d98f593f18d3c17b638753aa78741ee493519413d"

  depends_on "cmake" => :build
  depends_on "curl"
  depends_on "openssl"
  depends_on "pugixml"

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<-EOS.undent
      #include <webdav/client.hpp>
	  #include <iostream>
      #include <cassert>
      #include <string>
      #include <memory>
      #include <map>
      int main(int argc, char *argv[]) {
        std::map<std::string, std::string> options =
        {
          {"webdav_hostname", "https://webdav.example.com"},
          {"webdav_login",    "webdav_login"},
          {"webdav_password", "webdav_password"}
        };
        std::shared_ptr<WebDAV::Client> client(WebDAV::Client::Init(options));
        auto check_connection = client->check();
        assert(!check_connection);
		std::cout << "successfully";
      }
    EOS
    system ENV.cc,  "test.cpp", "-L#{lib}", "-lwebdavclient", "-lpthread",
                    "-lpugixml", "-lm", "-lcurl", "-lssl", "-lcrypto", 
                    "-lstdc++", "-std=c++11",
                    "-o", "test"
    system "./test"
  end
end
