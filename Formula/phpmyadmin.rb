class Phpmyadmin < Formula
  desc "Web interface for MySQL and MariaDB"
  homepage "https://www.phpmyadmin.net"
  url "https://files.phpmyadmin.net/phpMyAdmin/4.7.9/phpMyAdmin-4.7.9-all-languages.tar.gz"
  sha256 "2c66d6fb6f5921ac552c80755bf122c428675194b704a7aa692ee7cfa5faa2e1"
  head "https://github.com/phpmyadmin/phpmyadmin.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "a4fc107a3300e748eb2935919e21b64bff5ba3d2b58c2d96f43a617de672a070" => :high_sierra
    sha256 "a4fc107a3300e748eb2935919e21b64bff5ba3d2b58c2d96f43a617de672a070" => :sierra
    sha256 "a4fc107a3300e748eb2935919e21b64bff5ba3d2b58c2d96f43a617de672a070" => :el_capitan
  end

  depends_on "php" => :test

  def install
    pkgshare.install Dir["*"]

    unless File.exist?(etc+"phpmyadmin.config.inc.php")
      cp (pkgshare+"config.sample.inc.php"), (etc+"phpmyadmin.config.inc.php")
    end
    ln_s (etc+"phpmyadmin.config.inc.php"), (pkgshare+"config.inc.php")
  end

  def caveats; <<~EOS
    Note that this formula will NOT install mysql. It is not
    required since you might want to get connected to a remote
    database server.

    Webserver configuration example (add this at the end of
    your /etc/apache2/httpd.conf for instance) :
      Alias /phpmyadmin #{HOMEBREW_PREFIX}/share/phpmyadmin
      <Directory #{HOMEBREW_PREFIX}/share/phpmyadmin/>
        Options Indexes FollowSymLinks MultiViews
        AllowOverride All
        <IfModule mod_authz_core.c>
          Require all granted
        </IfModule>
        <IfModule !mod_authz_core.c>
          Order allow,deny
          Allow from all
        </IfModule>
      </Directory>
    Then, open http://localhost/phpmyadmin

    More documentation : file://#{pkgshare}/doc/

    Configuration has been copied to #{etc}/phpmyadmin.config.inc.php
    Don't forget to:
      - change your secret blowfish
      - uncomment the configuration lines (pma, pmapass ...)

    EOS
  end

  test do
    assert_predicate etc/"phpmyadmin.config.inc.php", :exist?

    Dir.chdir(pkgshare)
    system "php", pkgshare/"index.php"
  end
end
