class SpoofMac < Formula
  desc "Spoof your MAC address in OS X"
  homepage "https://github.com/feross/SpoofMAC"
  url "https://pypi.python.org/packages/9c/59/cc52a4c5d97b01fac7ff048353f8dc96f217eadc79022f78455e85144028/SpoofMAC-2.1.1.tar.gz"
  sha256 "48426efe033a148534e1d4dc224c4f1b1d22299c286df963c0b56ade4c7dc297"
  head "https://github.com/feross/SpoofMAC.git"

  bottle do
    cellar :any_skip_relocation
    rebuild 1
    sha256 "f3a9465720a89d8d5cd4eafa0d6e5d5e82cc9f8beaadfd0be18a115a474c9cd9" => :el_capitan
    sha256 "0fed4a6ef99045ec9c14b9dfda2811ff185b44e65b85dd1bc5bf9028837131b0" => :yosemite
    sha256 "0fed4a6ef99045ec9c14b9dfda2811ff185b44e65b85dd1bc5bf9028837131b0" => :mavericks
  end

  depends_on :python if MacOS.version <= :snow_leopard

  resource "docopt" do
    url "https://pypi.python.org/packages/source/d/docopt/docopt-0.6.2.tar.gz"
    sha256 "49b3a825280bd66b3aa83585ef59c4a8c82f2c8a522dbe754a8bc8d08c85c491"
  end

  def install
    ENV["PYTHONPATH"] = libexec/"lib/python2.7/site-packages"
    ENV.prepend_create_path "PYTHONPATH", libexec/"vendor/lib/python2.7/site-packages"

    resources.each do |r|
      r.stage { system "python", *Language::Python.setup_install_args(libexec/"vendor") }
    end

    system "python", *Language::Python.setup_install_args(libexec)
    bin.install Dir[libexec/"bin/*"]
    bin.env_script_all_files(libexec/"bin", :PYTHONPATH => ENV["PYTHONPATH"])
  end

  def caveats; <<-EOS.undent
    Although spoof-mac can run without root, you must be root to change the MAC.

    The launchdaemon is set to randomize en0.
    You can find the interfaces available by running:
        "spoof-mac list"

    If you wish to change interface randomized at startup change the plist line:
        <string>en0</string>
    to e.g.:
        <string>en1</string>
    EOS
  end

  plist_options :startup => true, :manual => "spoof-mac"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/spoof-mac</string>
          <string>randomize</string>
          <string>en0</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>StandardErrorPath</key>
        <string>/dev/null</string>
        <key>StandardOutPath</key>
        <string>/dev/null</string>
      </dict>
    </plist>
    EOS
  end

  test do
    system "#{bin}/spoof-mac", "list", "--wifi"
  end
end
