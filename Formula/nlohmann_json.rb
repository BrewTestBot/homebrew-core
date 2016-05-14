class NlohmannJson < Formula
  desc "JSON for Modern C++"
  homepage "https://github.com/nlohmann/json"
  url "https://github.com/nlohmann/json/archive/v1.1.0.tar.gz"
  sha256 "ee3825841e6d6915428caf2cea53927c3e4d56315a23ee7d1a64bfe1c19a656f"
  head "https://github.com/nlohmann/json.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "c19685f54d2fa35c77fadda85f98d6ce92801c2658ebdf6a6c54f88d59c21580" => :el_capitan
    sha256 "004707af4c875d4048c30cd7da353eb56b9255dd1bd1801c2544e16219a24224" => :yosemite
    sha256 "e36d65894bf3f0103f192d8185418fbf9889b3133e98dd59190bf5b0b16748d6" => :mavericks
  end

  def install
    include.install "src/json.hpp"
    ohai "to use the library, please set your include path accordingly:"
    ohai "CPPFLAGS: -I#{include}"
  end

  test do
    (testpath/"test.cpp").write <<-EOS.undent
      #include <json.hpp>

      using nlohmann::json;

      int main() {
        // create an empty structure (null)
        json j;

        // add a number that is stored as double (note the implicit conversion of j to an object)
        j["pi"] = 3.141;

        // add a Boolean that is stored as bool
        j["happy"] = true;

        // add a string that is stored as std::string
        j["name"] = "Niels";

        // add another null object by passing nullptr
        j["nothing"] = nullptr;

        // add an object inside the object
        j["answer"]["everything"] = 42;

        // add an array that is stored as std::vector (using an initializer list)
        j["list"] = { 1, 0, 2 };

        // add another object (using an initializer list of pairs)
        j["object"] = { {"currency", "USD"}, {"value", 42.99} };

        // instead, you could also write (which looks very similar to the JSON above)
        json j2 = {
          {"pi", 3.141},
          {"happy", true},
          {"name", "Niels"},
          {"nothing", nullptr},
          {"answer", {
            {"everything", 42}
          }},
          {"list", {1, 0, 2}},
          {"object", {
            {"currency", "USD"},
            {"value", 42.99}
          }}
        };
      }
    EOS
    system ENV.cxx, "test.cpp", "-I#{include}", "-std=c++11", "-o", "test"
    system "./test"
  end
end
