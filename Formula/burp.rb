class Burp < Formula
  desc "Network backup and restore"
  homepage "http://burp.grke.org/"

  stable do
    url "https://downloads.sourceforge.net/project/burp/burp-2.0.54/burp-2.0.54.tar.bz2"
    sha256 "ae10470586f1fee4556eaae5b3c52b78cfc0eac4109f4b8253c549e7ff000d86"

    resource "uthash" do
      url "https://github.com/troydhanson/uthash/archive/v2.0.1.tar.gz"
      sha256 "613b95fcc368b7d015ad2d0802313277012f50c4ac290c3dfc142d42ebea3337"
    end
  end

  bottle do
    rebuild 1
    sha256 "52a18ceee27e8fc65c9c45baea289639bcb5e0067821db4103cede0b8f6b3596" => :sierra
    sha256 "320060b3b3a3262ceaf76e340950edc4f37b3f89143b028f915374e6009c8944" => :el_capitan
    sha256 "18eb446b8b6dd3c098363522b81ec0d4c7511c91bd00fd61449acae4ad7f6e60" => :yosemite
  end

  devel do
    url "https://downloads.sourceforge.net/project/burp/burp-2.1.4/burp-2.1.4.tar.bz2"
    sha256 "acf29f7c99f1a61b69863a4774978d2da1e03852f35b679555923933113fccac"

    resource "uthash" do
      url "https://github.com/troydhanson/uthash.git",
          :revision => "7f1b50be94ceffcc7acd7a7f3f0f8f9aae52cc2f"
    end
  end

  head do
    url "https://github.com/grke/burp.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build

    resource "uthash" do
      url "https://github.com/troydhanson/uthash.git"
    end
  end

  depends_on "librsync"
  depends_on "openssl"

  def install
    resource("uthash").stage do
      system "make", "-C", "libut"
      (buildpath/"uthash/lib").install "libut/libut.a"
      (buildpath/"uthash/include").install Dir["src/*"]
    end

    ENV.prepend "CPPFLAGS", "-I#{buildpath}/uthash/include"
    ENV.prepend "LDFLAGS", "-L#{buildpath}/uthash/lib"

    system "autoreconf", "-fiv" if build.head?

    system "./configure", "--prefix=#{prefix}",
                          "--sysconfdir=#{etc}/burp",
                          "--sbindir=#{bin}",
                          "--localstatedir=#{var}"

    system "make", "install-all"
  end

  def post_install
    (var/"run").mkpath
    (var/"spool/burp").mkpath
  end

  def caveats; <<-EOS.undent
    Before installing the launchd entry you should configure your burp client in
      #{etc}/burp/burp.conf
    EOS
  end

  plist_options :startup => true

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>UserName</key>
      <string>root</string>
      <key>KeepAlive</key>
      <false/>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_bin}/burp</string>
        <string>-a</string>
        <string>t</string>
      </array>
      <key>StartInterval</key>
      <integer>1200</integer>
      <key>WorkingDirectory</key>
      <string>#{HOMEBREW_PREFIX}</string>
    </dict>
    </plist>
    EOS
  end

  test do
    system bin/"burp", "-v"
  end
end
