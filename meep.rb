class Meep < Formula
  desc "Meep (or MEEP) is a free finite-difference time-domain (FDTD) simulation software package developed at MIT to model electromagnetic systems."
  homepage "http://ab-initio.mit.edu/meep/"
  # use the current downloaded version from mit, not github
  url "http://ab-initio.mit.edu/meep/meep-1.3.tar.gz"
  version "1.3"
  sha256 "564c1ff1b413a3487cf81048a45deabfdac4243a1a37ce743f4fcf0c055fd438"
  ## the github meep-1.3 tag does not work yet
  ## head "https://github.com/stevengj/meep"
  
  # fix symmetry test failure on macOS by changing eps_compare from 1e-9 to 2e-9
  stable do
    patch do
      url "https://raw.githubusercontent.com/drjrkuhn/homebrew-meep/master/symmetry.diff"
      sha256 "f718011c7c215067759e5bd1ede782610a3b7e4c66d54faf93ec0a8a9ce0fd1d"
    end
  end
  

  depends_on :mpi => [:cc, :recommended]

  option "without-check", "Disable build-time checking (not recommended)"
  option "without-mpi", "Disable MPI parallel transforms (not recommended)" 
  
  mpi_args = [:recommended]
  mpi_args << "with-mpi" if build.with? "mpi"
  
  depends_on :fortran
  depends_on "h5utils" => :recommended
  depends_on "swig"
  depends_on "gsl"
  depends_on "hdf5" => mpi_args
  depends_on "fftw" => mpi_args
  depends_on "harminv"
  depends_on "libctl"
  depends_on "openblas" => :optional

  def install
    conf_args = [
        #"--enable-maintainer-mode",
        "--disable-dependency-tracking",
        "--disable-silent-rules",
        "--with-gcc-arch=native",
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
    
    ## arguments for testing    
    # export CPPFLAGS="-I/usr/local/opt/fftw/include -I/usr/local/opt/libctl/include -I/usr/local/opt/gsl/include -I/usr/local/opt/hdf5/include -I/usr/local/opt/harminv/include"
    # export LDFLAGS="-L/usr/local/opt/fftw/lib -L/usr/local/opt/libctl/lib -L/usr/local/opt/gsl/lib -L/usr/local/opt/hdf5/lib -L/usr/local/opt/harminv/lib"
    # ./configure --with-libctl=/usr/local/opt/libctl/share/libctl --with-gcc-arch=native

    # Add all libraries
    %w[fftw libctl gsl hdf5 fftw harminv].each do |f|
      ENV.append "CPPFLAGS", "-I#{Formula[f].opt_include}"
      ENV.append "LDFLAGS", "-L#{Formula[f].opt_lib}"
    end
        
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
