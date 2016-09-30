require 'formula'

class Harminv < Formula
  desc "Harminv solves the problem of harmonic inversion "
  homepage "http://ab-initio.mit.edu/wiki/index.php/Harminv"
  url "https://github.com/stevengj/harminv/archive/1.4.tar.gz"
  version "1.4"
  sha256 "3ea1b7727a163db7c86add2144d56822b659be43ee5d96ca559e071861760fb8"
  head "https://github.com/stevengj/harminv.git"

  option "without-check", "Disable build-time checking (not recommended)"
  depends_on :fortran
  depends_on "openblas" => :optional
  
  def install
    conf_args = [
        "--enable-maintainer-mode",
        "--disable-dependency-tracking",
        "--disable-silent-rules",
        "--prefix=#{prefix}"
      ]
    
    if build.with? "openblas"
      conf_args << "--with-blas=#{Formula["openblas"].opt_prefix}"
      conf_args << "--with-lapack=#{Formula["openblas"].opt_prefix}"
    elsif OS.mac?
      # otherwise, libblas and liblapack should be detected from Accelerator framework
    end
    
    # generate configure
    system "./autogen.sh"
    
    # Remove unrecognized options if warned by configure
    system "./configure", *conf_args
    
    system "make"
    system "make", "check" if build.with? "check"
    system "make", "install" # if this fails, try separate make/make install steps
  end

  test do
   system "make", "check"
  end
end
