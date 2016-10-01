require 'formula'

class Mpb < Formula
  desc "MIT Photonic-Bands (MPB) package"
  homepage "http://ab-initio.mit.edu/wiki/index.php/MIT_Photonic_Bands"
  url "http://ab-initio.mit.edu/mpb/mpb-1.5.tar.gz"
  version "1.5"
  sha256 "3deafe79185eb9eb8a8fe97d9fe51624221f51c1cf4baff4b4a7242c51130bd7"
  head "https://github.com/stevengj/mpb"

  depends_on :mpi => [:cc, :recommended]

  option "without-check", "Disable build-time checking (not recommended)"
  option "without-mpi", "Disable MPI parallel transforms (not recommended)" 
  option "with-openmp", "Enable OpenMP parallel transforms"
  option "with-inv-symmetry", "take advantage of (and require) inv. sym."
  option "with-hermitian-eps", "allow complex-Hermitian dielectric tensors"
  
  hdf5_args = []
  hdf5_args << "with-mpi" if build.with? "mpi"
  
  depends_on :fortran
  depends_on "fftw" => ["with-mpi" "with-openmp"]
  depends_on "libctl"
  depends_on "hdf5" => hdf5_args
  depends_on "openblas" => :optional
  depends_on "openmpi" => :optional
  needs :openmp if build.with? "openmp"

  def install
    conf_args = [
        "--enable-maintainer-mode",
        "--disable-dependency-tracking",
        "--disable-silent-rules",
        "--prefix=#{prefix}",
        "--with-libctl=#{Formula["libctl"].opt_prefix}/share/libctl"
      ]
    
    if build.with? "openblas"
      conf_args << "--with-blas=#{Formula["openblas"].opt_prefix}"
      conf_args << "--with-lapack=#{Formula["openblas"].opt_prefix}"
    elsif OS.mac?
      # otherwise, libblas and liblapack should be detected from Accelerator framework
    end
    
    conf_args << "--with-mpi" if build.with? "mpi"
    conf_args << "--with-openmp" if build.with? "openmp"
    conf_args << "--with-inv-symmetry" if build.with? "inv-symmetry"
    conf_args << "--with-hermitian-eps" if build.with? "hermitian-eps"
        
    
    ENV.append "CPPFLAGS", "-I#{Formula["fftw"].include} -I#{Formula["libctl"].include}"
    ENV.append "LDFLAGS",  "-L#{Formula["fftw"].lib} -L#{Formula["libctl"].lib}"
    
    system "autoreconf", "-fiv"
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
