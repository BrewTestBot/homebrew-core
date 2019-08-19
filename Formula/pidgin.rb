class Pidgin < Formula
  desc "Multi-protocol chat client"
  homepage "https://pidgin.im/"
  url "https://downloads.sourceforge.net/project/pidgin/Pidgin/2.13.0/pidgin-2.13.0.tar.bz2"
  sha256 "2747150c6f711146bddd333c496870bfd55058bab22ffb7e4eb784018ec46d8f"
  revision 4

  bottle do
    sha256 "2b9c765109f9f7466f03917f5a2f94fef859c3aee2ca0464dcac3b932bf36f02" => :mojave
    sha256 "4010032a68be713ea9769637f5cb3baf7a6b1914739b47103c1f6b50f3783717" => :high_sierra
    sha256 "902f763d49ecb87766394da0b1d641906e06c6a4d588251ca12d9d13ceb4c4de" => :sierra
  end

  depends_on "intltool" => :build
  depends_on "pkg-config" => :build
  depends_on "cairo"
  depends_on "gettext"
  depends_on "glib"
  depends_on "gnutls"
  depends_on "gtk+"
  depends_on "libgcrypt"
  depends_on "libidn"
  depends_on "libotr"
  depends_on "pango"

  # Finch has an equal port called purple-otr but it is a NIGHTMARE to compile
  # If you want to fix this and create a PR on Homebrew please do so.
  resource "pidgin-otr" do
    url "https://otr.cypherpunks.ca/pidgin-otr-4.0.2.tar.gz"
    sha256 "f4b59eef4a94b1d29dbe0c106dd00cdc630e47f18619fc754e5afbf5724ebac4"
  end

  resource "purple-add-prefix" do
    url "https://github.com/kgraefe/purple-add-prefix/releases/download/v1.0/addprefix-1.0.tar.gz"
    sha256 "d3d71cfdb375ec877a223b49c88c6dac27891ab9c0cd00d1a32a8aecfe3bb281"
  end

  def install
    args = %W[
      --disable-debug
      --disable-dependency-tracking
      --prefix=#{prefix}
      --disable-avahi
      --disable-dbus
      --disable-doxygen
      --disable-gevolution
      --disable-gstreamer
      --disable-gstreamer-interfaces
      --disable-gtkspell
      --disable-meanwhile
      --disable-vv
      --enable-gnutls=yes
      --with-tclconfig=#{MacOS.sdk_path}/System/Library/Frameworks/Tcl.framework
      --with-tkconfig=#{MacOS.sdk_path}/System/Library/Frameworks/Tk.framework
      --without-x
    ]

    ENV["ac_cv_func_perl_run"] = "yes" if MacOS.version == :high_sierra

    system "./configure", *args
    system "make", "install"

    resource("pidgin-otr").stage do
      ENV.prepend "CFLAGS", "-I#{Formula["libotr"].opt_include}"
      ENV.append_path "PKG_CONFIG_PATH", "#{lib}/pkgconfig"
      system "./configure", "--prefix=#{prefix}", "--mandir=#{man}"
      system "make", "install"
    end

    resource("purple-add-prefix").stage do
      system "make", "install", "ADD_PREFIX=#{HOMEBREW_PREFIX}"
    end
  end

  test do
    system "#{bin}/finch", "--version"
  end
end
