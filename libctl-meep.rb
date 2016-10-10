# Documentation: https://github.com/Homebrew/brew/blob/master/docs/Formula-Cookbook.md
#                http://www.rubydoc.info/github/Homebrew/brew/master/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!

class LibctlMeep < Formula
  desc "Guile-based library for supporting flexible control files in scientific simulations"
  homepage "http://ab-initio.mit.edu/wiki/index.php/Libctl"
  url "http://ab-initio.mit.edu/libctl/libctl-3.2.2.tar.gz"
  head "https://github.com/stevengj/libctl.git"
  sha256 "3ea1b7727a163db7c86add2144d56822b659be43ee5d96ca559e071861760fb8"
  version "3.2.2"

  fails_with :clang
  fails_with :gcc => "4.6" do
    cause "The only supported compiler is GCC(>=4.7)."
  end

  option "without-check", "Disable build-time checking (not recommended)"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "gettext" => :build

  depends_on :fortran
  
  def install
    conf_args = [
        "--enable-maintainer-mode",
        "--disable-dependency-tracking",
        "--disable-silent-rules",
        "--enable-shared",
        "--prefix=#{prefix}"
      ]
  
    ENV.append "CPLUS_INCLUDE_PATH", "#{HOMEBREW_PREFIX}/include"
    ENV.append "LIBRARY_PATH", "#{HOMEBREW_PREFIX}/lib"

#    if build.head?
      system "./autogen.sh"
#    else
#      system "autoreconf", "-fiv"
#    end
    system "./configure", *conf_args

    system "make"
    system "make", "check" if build.with? "check"
    system "make", "install" # if this fails, try separate make/make install steps
  end

  test do
    # make check above
    system "false"
  end
end
