class Nginx < Formula
  desc "HTTP(S) server and reverse proxy, and IMAP/POP3 proxy server"
  homepage "https://nginx.org/"
  url "https://nginx.org/download/nginx-1.12.1.tar.gz"
  sha256 "8793bf426485a30f91021b6b945a9fd8a84d87d17b566562c3797aba8fac76fb"

  head "https://hg.nginx.org/nginx/", :using => :hg

  bottle do
    rebuild 1
    sha256 "ab301feb17ce9a4cde3f0f1ce991397d0d74094c627a159aed9fc7ec810a653f" => :sierra
    sha256 "88a19c33a33a42297d42a63d159b17a4c5c4f1be95dd734099e93996043a69c6" => :el_capitan
    sha256 "fc44d0c58f30f2756dad77cab68c3c5383c852bb7df8f8db1d04502a4f0ab9f6" => :yosemite
  end

  devel do
    url "https://nginx.org/download/nginx-1.13.5.tar.gz"
    sha256 "0e75b94429b3f745377aeba3aff97da77bf2b03fcb9ff15b3bad9b038db29f2e"
  end

  # Before submitting more options to this formula please check they aren't
  # already in Homebrew/homebrew-nginx/nginx-full:
  # https://github.com/Homebrew/homebrew-nginx/blob/master/Formula/nginx-full.rb
  option "with-passenger", "Compile with support for Phusion Passenger module"
  option "with-webdav", "Compile with support for WebDAV module"
  option "with-debug", "Compile with support for debug log"
  option "with-gunzip", "Compile with support for gunzip module"

  depends_on "pcre"
  depends_on "passenger" => :optional

  # passenger uses apr, which uses openssl, so need to keep
  # crypto library choice consistent throughout the tree.
  if build.with? "passenger"
    depends_on "openssl"
  else
    depends_on "openssl@1.1"
  end

  def install
    # Changes default port to 8080
    inreplace "conf/nginx.conf" do |s|
      s.gsub! "listen       80;", "listen       8080;"
      s.gsub! "    #}\n\n}", "    #}\n    include servers/*;\n}"
    end

    pcre = Formula["pcre"]

    if build.with? "passenger"
      openssl = Formula["openssl"]
    else
      openssl = Formula["openssl@1.1"]
    end

    cc_opt = "-I#{pcre.opt_include} -I#{openssl.opt_include}"
    ld_opt = "-L#{pcre.opt_lib} -L#{openssl.opt_lib}"

    args = %W[
      --prefix=#{prefix}
      --with-http_ssl_module
      --with-pcre
      --sbin-path=#{bin}/nginx
      --with-cc-opt=#{cc_opt}
      --with-ld-opt=#{ld_opt}
      --conf-path=#{etc}/nginx/nginx.conf
      --pid-path=#{var}/run/nginx.pid
      --lock-path=#{var}/run/nginx.lock
      --http-client-body-temp-path=#{var}/run/nginx/client_body_temp
      --http-proxy-temp-path=#{var}/run/nginx/proxy_temp
      --http-fastcgi-temp-path=#{var}/run/nginx/fastcgi_temp
      --http-uwsgi-temp-path=#{var}/run/nginx/uwsgi_temp
      --http-scgi-temp-path=#{var}/run/nginx/scgi_temp
      --http-log-path=#{var}/log/nginx/access.log
      --error-log-path=#{var}/log/nginx/error.log
      --with-http_gzip_static_module
      --with-http_v2_module
    ]

    if build.with? "passenger"
      nginx_ext = `#{Formula["passenger"].opt_bin}/passenger-config --nginx-addon-dir`.chomp
      args << "--add-module=#{nginx_ext}"
    end

    args << "--with-http_dav_module" if build.with? "webdav"
    args << "--with-debug" if build.with? "debug"
    args << "--with-http_gunzip_module" if build.with? "gunzip"

    if build.head?
      system "./auto/configure", *args
    else
      system "./configure", *args
    end

    system "make", "install"
    if build.head?
      man8.install "docs/man/nginx.8"
    else
      man8.install "man/nginx.8"
    end
  end

  def post_install
    (etc/"nginx/servers").mkpath
    (var/"run/nginx").mkpath

    # nginx's docroot is #{prefix}/html, this isn't useful, so we symlink it
    # to #{HOMEBREW_PREFIX}/var/www. The reason we symlink instead of patching
    # is so the user can redirect it easily to something else if they choose.
    html = prefix/"html"
    dst = var/"www"

    if dst.exist?
      html.rmtree
      dst.mkpath
    else
      dst.dirname.mkpath
      html.rename(dst)
    end

    prefix.install_symlink dst => "html"

    # for most of this formula's life the binary has been placed in sbin
    # and Homebrew used to suggest the user copy the plist for nginx to their
    # ~/Library/LaunchAgents directory. So we need to have a symlink there
    # for such cases
    if rack.subdirs.any? { |d| d.join("sbin").directory? }
      sbin.install_symlink bin/"nginx"
    end
  end

  def passenger_caveats; <<-EOS.undent
    To activate Phusion Passenger, add this to #{etc}/nginx/nginx.conf, inside the 'http' context:
      passenger_root #{Formula["passenger"].opt_libexec}/src/ruby_supportlib/phusion_passenger/locations.ini;
      passenger_ruby /usr/bin/ruby;
    EOS
  end

  def caveats
    s = <<-EOS.undent
    Docroot is: #{var}/www

    The default port has been set in #{etc}/nginx/nginx.conf to 8080 so that
    nginx can run without sudo.

    nginx will load all files in #{etc}/nginx/servers/.
    EOS
    s << "\n" << passenger_caveats if build.with? "passenger"
    s
  end

  plist_options :manual => "nginx"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>RunAtLoad</key>
        <true/>
        <key>KeepAlive</key>
        <false/>
        <key>ProgramArguments</key>
        <array>
            <string>#{opt_bin}/nginx</string>
            <string>-g</string>
            <string>daemon off;</string>
        </array>
        <key>WorkingDirectory</key>
        <string>#{HOMEBREW_PREFIX}</string>
      </dict>
    </plist>
    EOS
  end

  test do
    (testpath/"nginx.conf").write <<-EOS
      worker_processes 4;
      error_log #{testpath}/error.log;
      pid #{testpath}/nginx.pid;

      events {
        worker_connections 1024;
      }

      http {
        client_body_temp_path #{testpath}/client_body_temp;
        fastcgi_temp_path #{testpath}/fastcgi_temp;
        proxy_temp_path #{testpath}/proxy_temp;
        scgi_temp_path #{testpath}/scgi_temp;
        uwsgi_temp_path #{testpath}/uwsgi_temp;

        server {
          listen 8080;
          root #{testpath};
          access_log #{testpath}/access.log;
          error_log #{testpath}/error.log;
        }
      }
    EOS
    system bin/"nginx", "-t", "-c", testpath/"nginx.conf"
  end
end
