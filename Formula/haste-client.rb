class HasteClient < Formula
  desc "CLI client for haste-server"
  homepage "https://hastebin.com/"
  url "https://github.com/seejohnrun/haste-client/archive/v0.2.2.tar.gz"
  sha256 "489ea560e788256ca1ca96a5efa4457a9e70c4f7893a760083c7d9f42b272f6b"
  head "https://github.com/seejohnrun/haste-client.git"

  depends_on :ruby => "2.3"

  resource "faraday" do
    url "https://rubygems.org/gems/faraday-0.12.1.gem"
    sha256 "0350b3d3adc9418e4e761198866709fc1b27db116cf52484989aa94d084a7df2"
  end

  resource "multipart-post" do
    url "https://rubygems.org/gems/multipart-post-2.0.0.gem"
    sha256 "3dc44e50d3df3d42da2b86272c568fd7b75c928d8af3cc5f9834e2e5d9586026"
  end

  def install
    ENV["GEM_HOME"] = libexec
    resources.each do |r|
      r.verify_download_integrity(r.fetch)
      system "gem", "install", r.cached_download, "--no-document",
             "--install-dir", libexec
    end
    system "gem", "build", "haste.gemspec"
    system "gem", "install", "--ignore-dependencies", "haste-#{version}.gem"
    bin.install libexec/"bin/haste"
    bin.env_script_all_files(libexec/"bin", :GEM_HOME => ENV["GEM_HOME"])
  end

  test do
    output = pipe_output("#{bin}/haste", "testing", 0)
    assert_match(%r{^https://hastebin\.com/.+}, output)
  end
end
