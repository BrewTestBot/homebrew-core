class Suricata < Formula
  desc "Network IDS, IPS, and security monitoring engine"
  homepage "https://suricata-ids.org/"
  url "https://www.openinfosecfoundation.org/download/suricata-4.0.3.tar.gz"
  sha256 "81a0bcb10b5c0b00efeafb4aac3ef70bf0e36b060ac6300d867f15f3dbe0e437"

  bottle do
    rebuild 1
    sha256 "0b51cdc5cb1e071cc5d6d34101c472ffbffc899f29850d6d5cae3dfa4ce6d4c5" => :high_sierra
    sha256 "d06a59d4bae6522a6f5352d713327ff60ff349688783c4d29e5605052b8a1985" => :sierra
    sha256 "b987a1691a1464d96dda4f05aa3b596c845c3998adc0d12421fe6c7b437b1e23" => :el_capitan
  end

  depends_on "python" if MacOS.version <= :snow_leopard
  depends_on "pkg-config" => :build
  depends_on "libmagic"
  depends_on "libnet"
  depends_on "libyaml"
  depends_on "pcre"
  depends_on "nss"
  depends_on "nspr"
  depends_on "geoip" => :optional
  depends_on "lua" => :optional
  depends_on "luajit" => :optional
  depends_on "jansson" => :optional
  depends_on "hiredis" => :optional

  resource "argparse" do
    url "https://files.pythonhosted.org/packages/source/a/argparse/argparse-1.4.0.tar.gz"
    sha256 "62b089a55be1d8949cd2bc7e0df0bddb9e028faefc8c32038cc84862aefdd6e4"
  end

  resource "simplejson" do
    url "https://files.pythonhosted.org/packages/source/s/simplejson/simplejson-3.13.2.tar.gz"
    sha256 "4c4ecf20e054716cc1e5a81cadc44d3f4027108d8dd0861d8b1e3bd7a32d4f0a"
  end

  def install
    libnet = Formula["libnet"]
    libmagic = Formula["libmagic"]

    ENV.prepend_create_path "PYTHONPATH", libexec/"vendor/lib/python2.7/site-packages"
    resources.each do |r|
      r.stage do
        system "python", *Language::Python.setup_install_args(libexec/"vendor")
      end
    end

    args = %W[
      --disable-dependency-tracking
      --disable-silent-rules
      --prefix=#{prefix}
      --sysconfdir=#{etc}
      --localstatedir=#{var}
      --with-libnet-includes=#{libnet.opt_include}
      --with-libnet-libs=#{libnet.opt_lib}
      --with-libmagic-includes=#{libmagic.opt_include}
      --with-libmagic-libraries=#{libmagic.opt_lib}
    ]

    args << "--enable-lua" if build.with? "lua"
    args << "--enable-luajit" if build.with? "luajit"

    if build.with? "geoip"
      geoip = Formula["geoip"]
      args << "--enable-geoip"
      args << "--with-libgeoip-includes=#{geoip.opt_include}"
      args << "--with-libgeoip-libs=#{geoip.opt_lib}"
    end

    if build.with? "jansson"
      jansson = Formula["jansson"]
      args << "--with-libjansson-includes=#{jansson.opt_include}"
      args << "--with-libjansson-libraries=#{jansson.opt_lib}"
    end

    if build.with? "hiredis"
      hiredis = Formula["hiredis"]
      args << "--enable-hiredis"
      args << "--with-libhiredis-includes=#{hiredis.opt_include}"
      args << "--with-libhiredis-libraries=#{hiredis.opt_lib}"
    end
    system "./configure", *args
    system "make", "install-full"

    bin.env_script_all_files(libexec/"bin", :PYTHONPATH => ENV["PYTHONPATH"])

    # Leave the magic-file: prefix in otherwise it overrides a commented out line rather than intended line.
    inreplace etc/"suricata/suricata.yaml", %r{magic-file: /.+/magic}, "magic-file: #{libmagic.opt_share}/misc/magic"
  end

  test do
    assert_match(/#{version}/, shell_output("#{bin}/suricata --build-info"))
  end
end
