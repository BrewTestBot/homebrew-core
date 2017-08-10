class Scanssh < Formula
  desc "Scan for SSH and open proxies"
  homepage "https://www.monkey.org/~provos/scanssh/"
  url "https://www.monkey.org/~provos/scanssh-2.1.tar.gz"
  sha256 "057eec87edafbbe5bc22960cbac53e3ada0222400d649a5e2f22cc8981f5b035"

  bottle do
    cellar :any
    sha256 "770a8d7ad3a50828eef36454c910f8c587356c3fc9eb9f0895c1522ddcb2cec4" => :sierra
    sha256 "15e2a9c696717025cc5d179e99f720b4bd1789bbb14cf5c1e96ac5d234bd3415" => :el_capitan
    sha256 "2703138bb2262a3b983c8e9606cfa92e11ba77d8e395ffbeb20210d7a81282a4" => :yosemite
  end

  depends_on "libevent" => :build
  depends_on "libdnet" => :build

  patch :p0, :DATA

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--with-libdnet=#{Formula["libdnet"].opt_prefix}/",
                          "--with-libevent=#{HOMEBREW_PREFIX}",
                          "--mandir=#{man}",
                          "--prefix=#{prefix}"

    system "make", "install"
  end

  test do
    system "#{bin}/scanssh", "-V"
  end
end

__END__
--- configure	2005-03-05 19:21:31.000000000 +0000
+++ /private/tmp/scanssh-20170810-13773-8ohthr/scanssh-2.1/.brew_home/configure.scanssh	2017-08-10 13:06:51.000000000 +0100
@@ -2795,6 +2795,11 @@
         if cd $withval; then withval=`pwd`; cd $owd; fi
         EVENTINC="-I$withval"
         EVENTLIB="-L$withval -levent"
+     elif test -f $withval/include/event.h -a -f $withval/lib/libevent.a; then
+        owd=`pwd`
+        if cd $withval; then withval=`pwd`; cd $owd; fi
+        EVENTINC="-I$withval"
+        EVENTLIB="-L$withval -levent"
      else
         { { echo "$as_me:2799: error: event.h or libevent.a not found in $withval" >&5
 echo "$as_me: error: event.h or libevent.a not found in $withval" >&2;}
--- scanssh.c.orig	2017-08-10 13:48:53.000000000 +0100
+++ scanssh.c	2017-08-10 13:49:04.000000000 +0100
@@ -1153,26 +1153,10 @@
 	/* Raising file descriptor limits */
 	rl.rlim_max = RLIM_INFINITY;
 	rl.rlim_cur = RLIM_INFINITY;
-	if (setrlimit(RLIMIT_NOFILE, &rl) == -1) {
-		/* Linux does not seem to like this */
-		if (getrlimit(RLIMIT_NOFILE, &rl) == -1)
-			err(1, "getrlimit: NOFILE");
-		rl.rlim_cur = rl.rlim_max;
-		if (setrlimit(RLIMIT_NOFILE, &rl) == -1)
-			err(1, "setrlimit: NOFILE");
-	}
 
 	/* Raising the memory limits */
 	rl.rlim_max = RLIM_INFINITY;
 	rl.rlim_cur = MAXSLOTS * EXPANDEDARGS * sizeof(struct argument) * 2;
-	if (setrlimit(RLIMIT_DATA, &rl) == -1) {
-		/* Linux does not seem to like this */
-		if (getrlimit(RLIMIT_DATA, &rl) == -1)
-			err(1, "getrlimit: DATA");
-		rl.rlim_cur = rl.rlim_max;
-		if (setrlimit(RLIMIT_DATA, &rl) == -1)
-			err(1, "setrlimit: DATA");
-	}
 	
        
 	/* revoke privs */
