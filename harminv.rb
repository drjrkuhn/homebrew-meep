require 'formula'

class Harminv < Formula
  desc "Harminv solves the problem of harmonic inversion."
  homepage "http://ab-initio.mit.edu/wiki/index.php/Harminv"
  url "https://github.com/stevengj/harminv/archive/1.4.tar.gz"
  version "1.4"
  sha256 "3ea1b7727a163db7c86add2144d56822b659be43ee5d96ca559e071861760fb8"
  head "https://github.com/stevengj/harminv.git"
  
  option "with-gnu", "force compilation with gnu compiler rather than clang"
  if build.with? "gcc"
    fails_with :clang
    fails_with :gcc => "4.6" do
      cause "The only supported compiler is GCC(>=4.7)."
    end
  end

  option "without-check", "Disable build-time checking (not recommended)"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "gettext" => :build

  depends_on :fortran
  depends_on "openblas" => :optional
  
  def install
    conf_args = [
        "--enable-maintainer-mode",
        "--disable-dependency-tracking",
        "--disable-silent-rules",
        "--enable-shared",
        "--prefix=#{prefix}"
      ]
  
    # openblas is keg-only. We need to link to it if installed  
    if build.with? "openblas"
      conf_args << "--with-blas=#{Formula["openblas"].opt_prefix}"
      conf_args << "--with-lapack=#{Formula["openblas"].opt_prefix}"
    elsif OS.mac?
      # otherwise, libblas and liblapack should be detected from Accelerator framework
    end
    
    ENV.append "CPLUS_INCLUDE_PATH", "#{HOMEBREW_PREFIX}/include"
    ENV.append "LIBRARY_PATH", "#{HOMEBREW_PREFIX}/lib"

    if build.head?
      system "./autogen.sh"
    else
      system "autoreconf", "-fiv"
    end
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
