class ApacheForrest < Formula
  desc "Publishing framework providing multiple output formats"
  homepage "https://forrest.apache.org/"
  url "https://www.apache.org/dyn/closer.cgi?path=forrest/apache-forrest-0.9-sources.tar.gz"
  mirror "https://archive.apache.org/dist/forrest/apache-forrest-0.9-sources.tar.gz"
  sha256 "c6ac758db2eb0d4d91bd1733bbbc2dec4fdb33603895c464bcb47a34490fb64d"
  revision 1

  bottle do
    cellar :any_skip_relocation
    rebuild 1
    sha256 "e4ba347a1bc6ffa38a2cab0344ccc4f4dc10c2e496d4b31a8e698aa5ebaa175f" => :catalina
    sha256 "e4ba347a1bc6ffa38a2cab0344ccc4f4dc10c2e496d4b31a8e698aa5ebaa175f" => :mojave
    sha256 "e4ba347a1bc6ffa38a2cab0344ccc4f4dc10c2e496d4b31a8e698aa5ebaa175f" => :high_sierra
  end

  depends_on "openjdk"

  resource "deps" do
    url "https://www.apache.org/dyn/closer.cgi?path=forrest/apache-forrest-0.9-dependencies.tar.gz"
    sha256 "33146b4e64933691d3b779421b35da08062a704618518d561281d3b43917ccf1"
  end

  def install
    libexec.install Dir["*"]
    (bin/"forrest").write_env_script libexec/"bin/forrest", :JAVA_HOME => Formula["openjdk"].opt_prefix

    resource("deps").stage do
      # To avoid conflicts with directory names already installed from the
      # main tarball, surgically install contents of dependency tarball
      deps_to_install = [
        "lib",
        "main/webapp/resources/schema/relaxng",
        "main/webapp/resources/stylesheets",
        "plugins/org.apache.forrest.plugin.output.pdf/",
        "tools/ant",
        "tools/forrestbot/lib",
        "tools/forrestbot/webapp/lib",
        "tools/jetty",
      ]
      deps_to_install.each do |dep|
        (libexec/dep).install Dir["#{dep}/*"]
      end
    end
  end

  test do
    system "#{bin}/forrest", "-projecthelp"
  end
end
