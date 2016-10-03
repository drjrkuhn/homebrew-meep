require 'formula'

class Mpb < Formula
  desc "MIT Photonic-Bands (MPB) package"
  homepage "http://ab-initio.mit.edu/wiki/index.php/MIT_Photonic_Bands"
  url "http://ab-initio.mit.edu/mpb/mpb-1.5.tar.gz"
  version "1.5"
  sha256 "3deafe79185eb9eb8a8fe97d9fe51624221f51c1cf4baff4b4a7242c51130bd7"
  head "https://github.com/stevengj/mpb"

  fails_with :clang do
    cause "The only supported compiler is GCC(>=4.7)."
  end

  depends_on :fortran
  depends_on :mpi => [:cc, :optional]

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "gettext" => :build

  option "without-check", "Disable build-time checking (not recommended)"
  option "with-openmp", "Enable OpenMP parallel transforms"
  option "with-inv-symmetry", "take advantage of (and require) inv. sym."
  option "with-hermitian-eps", "allow complex-Hermitian dielectric tensors"
  
  if build.with? "openmp"
    # fftw needs to be recompiled with openmp if mpb requests openmp
    depends_on "fftw" => ["with-mpi" "with-openmp"]
  else
    depends_on "fftw"
  end
  depends_on "libctl"
  depends_on "hdf5"
  depends_on "openblas" => :optional
  depends_on "openmpi" => :optional
  needs :openmp if build.with? "openmp"

  def install
    conf_args = [
        "--enable-maintainer-mode",
        "--disable-dependency-tracking",
        "--disable-silent-rules",
        "--prefix=#{prefix}",
        #"--with-libctl=#{Formula["libctl"].opt_prefix}/share/libctl"
        "--with-libctl=#{HOMEBREW_PREFIX}/share/libctl"
      ]
    
    
    # openblas is keg-only. We need to link to it if installed  
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
        
    ENV.append "CPPFLAGS", "-I#{HOMEBREW_PREFIX}/include"
    ENV.append "LDFLAGS", "-L#{HOMEBREW_PREFIX}/lib"
    
    system "autoreconf", "-fiv"
    system "./configure", *conf_args
  
    system "make"
    system "make", "check" if build.with? "check"
    system "make", "install" # if this fails, try separate make/make install steps
    bin.install_symlink "mpb-mpi" => "mpb" if build.with? "mpi"
  end

  test do
    # make check above
    system "false"
  end
end
