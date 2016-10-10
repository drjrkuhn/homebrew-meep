require 'formula'

class Mpb < Formula
  desc "MIT Photonic-Bands (MPB) package"
  homepage "http://ab-initio.mit.edu/wiki/index.php/MIT_Photonic_Bands"
  url "http://ab-initio.mit.edu/mpb/mpb-1.5.tar.gz"
  version "1.5"
  sha256 "3deafe79185eb9eb8a8fe97d9fe51624221f51c1cf4baff4b4a7242c51130bd7"
  head "https://github.com/stevengj/mpb.git"

  fails_with :clang
  fails_with :gcc => "4.6" do
    cause "The only supported compiler is GCC(>=4.7)."
  end

  depends_on :fortran
  depends_on :mpi => [:cc, :recommended]

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "gettext" => :build

  option "without-check", "Disable build-time checking (not recommended)"

  option "with-inv-symmetry", "take advantage of (and require) inv. sym."
  option "with-hermitian-eps", "allow complex-Hermitian dielectric tensors"
  
  depends_on "fftw"
  depends_on "libctl-meep" => :recommended
  depends_on "hdf5"
  depends_on "openblas" => :optional

  def install

    # homebrew standard libraries        
    ENV.append "CPLUS_INCLUDE_PATH", "#{HOMEBREW_PREFIX}/include"
    ENV.append "LIBRARY_PATH", "#{HOMEBREW_PREFIX}/lib"

    ## Position Independent Code, needed on 64-bit
    ENV.append "CXXLAGS", " -fPIC -Wno-mismatched-tags"
    ENV.append "CFLAGS", " -fPIC"
    ENV.append "FFLAGS", " -fPIC"

    conf_args = [
        "--enable-maintainer-mode",
        "--disable-dependency-tracking",
        "--disable-silent-rules",
        "--enable-shared",
        "--prefix=#{prefix}",
      ]
    conf_args << "--with-inv-symmetry" if build.with? "inv-symmetry"
    conf_args << "--with-hermitian-eps" if build.with? "hermitian-eps"
    
    # openblas is keg-only. We need to link to it if installed  
    if build.with? "openblas"
      conf_args << "--with-blas=#{Formula["openblas"].opt_prefix}"
      conf_args << "--with-lapack=#{Formula["openblas"].opt_prefix}"
    elsif OS.mac?
      # otherwise, libblas and liblapack should be detected from Accelerator framework
    end
    
    if build.with? "libctl-meep"    
      conf_args << "--with-libctl=#{HOMEBREW_PREFIX}/share/libctl-meep"
    else
      conf_args << "--without-libctl"
    end
    
    if build.with? "mpi"
      conf_args << "--with-mpi" if build.with? "mpi"
      ENV.append "LDFLAGS", " -lmpi"
    end
    
    if build.head?
      system "./autogen.sh"
    else
      system "autoreconf", "-fiv"
    end
    system "./configure", *conf_args
  
    system "make"
    system "make", "install" # if this fails, try separate make/make install steps
    system "make", "check" if build.with? "check"
    bin.install_symlink "mpb-mpi" => "mpb" if build.with? "mpi"
  end

  test do
    # make check above
    system "false"
  end
end
