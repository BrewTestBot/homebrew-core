class Appsody < Formula
  desc "This is the formula for the Appsody command-line interface"
  homepage "https://www.appsody.dev"
  url "https://github.com/appsody/appsody/releases/download/0.2.4/appsody-homebrew-0.2.4.tar.gz"
  sha256 "d8ea67620e80e88ee0cd00807ebe8eb6a4ed730b86b47dddb1920c4458c4ad07"

  bottle do
  end
  def install
    bin.install "appsody"
    bin.install "appsody-controller"
    ohai "Checking prerequisites..."
    retval=check_prereqs

    if retval
      ohai "Done."
    else
      opoo "Docker not detected. Please ensure docker is installed and running before using appsody."
    end
  end

  def check_prereqs
    begin
      original_stderr = $stderr.clone
      original_stdout = $stdout.clone
      $stderr.reopen(File.new("/dev/null", "w"))
      $stdout.reopen(File.new("/dev/null", "w"))
      begin
        system("/usr/local/bin/docker", "ps")
        retval=true
      rescue
        retval=false
      end
    rescue => e
      $stdout.reopen(original_stdout)
      $stderr.reopen(original_stderr)
      raise e
    ensure
      $stdout.reopen(original_stdout)
      $stderr.reopen(original_stderr)
    end
    retval
  end

  test do
    assert_match "Passed", shell_output("test -f #{bin}/appsody && echo Passed")
    assert_match "Passed", shell_output("test -f #{bin}/appsody-controller && echo Passed")
  end
end
