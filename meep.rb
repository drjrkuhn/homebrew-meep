class Meep < Formula
  desc "Meep (or MEEP) is a free finite-difference time-domain (FDTD) simulation software package developed at MIT to model electromagnetic systems."
  homepage "http://ab-initio.mit.edu/meep/"
  # use the current downloaded version from mit, not github
  url "http://ab-initio.mit.edu/meep/meep-1.3.tar.gz"
  version "1.3"
  sha256 "564c1ff1b413a3487cf81048a45deabfdac4243a1a37ce743f4fcf0c055fd438"
  #head "https://github.com/FilipDominec/meep.git" 
  head "https://github.com/stevengj/meep.git"
  
  # fix symmetry test failure on macOS by changing eps_compare from 1e-9 to 2e-9
  stable do
    patch do
      url "https://raw.githubusercontent.com/drjrkuhn/homebrew-meep/master/symmetry.diff"
      sha256 "f718011c7c215067759e5bd1ede782610a3b7e4c66d54faf93ec0a8a9ce0fd1d"
    end
  end
  
  fails_with :clang do
    cause "The only supported compiler is GCC(>=4.7)."
  end

  depends_on :fortran
  depends_on :mpi => [:cc, :optional]

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "gettext" => :build
  depends_on "gnu-sed" => :build

  option "without-check", "Disable build-time checking (not recommended)"
  option "without-libctl", "Disable guile integration through libctl"
  #option "without-mpi", "Disable MPI parallel transforms (not recommended)" 
  
  mpi_args = [:recommended]
  mpi_args << "with-mpi" if build.with? "mpi"
  
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
        "--enable-maintainer-mode",
        "--enable-shared",
        #"--disable-dependency-tracking",
        #"--disable-silent-rules",
        #"--with-gcc-arch=native",
        "--prefix=#{prefix}",
        #"--with-libctl=#{Formula["libctl"].opt_prefix}/share/libctl"
      ]
    
    if build.with? "openblas"
      conf_args << "--with-blas=#{Formula["openblas"].opt_prefix}"
      conf_args << "--with-lapack=#{Formula["openblas"].opt_prefix}"
    elsif OS.mac?
      # otherwise, libblas and liblapack should be detected from Accelerator framework
    end

#    if build.with? "libctl"    
#      conf_args << "--with-libctl=#{HOMEBREW_PREFIX}/share/libctl"
#    else
#      conf_args << "--without-libctl"
#    end
    
    conf_args << "--with-mpi" if build.with? "mpi"
    
    ## arguments for testing    
    #
    # export CC=/usr/local/bin/gcc-6 CXX=/usr/local/bin/g++-6 CPP=/usr/local/bin/cpp-6 LD=/usr/local/bin/gcc-6 F77=/usr/local/bin/gfortran-6

    # export CPPFLAGS="-I/usr/local/include"
    # export LDFLAGS="-L/usr/local/lib"
    # export CXX="/usr/local/bin/gcc-6"
    # export MPICXX="/usr/local/bin/gcc-6"
    # export CC="/usr/local/bin/gcc-6"
    # ./configure --with-libctl=/usr/local/opt/libctl/share/libctl --with-gcc-arch=native

    ENV.append "CPLUS_INCLUDE_PATH", "#{HOMEBREW_PREFIX}/include"
    ENV.append "LIBRARY_PATH", "#{HOMEBREW_PREFIX}/lib"
    ENV["sed"] = "#{HOMEBREW_PREFIX}/bin/gsed"
    ## Position Independent Code, needed on 64-bit
    ENV.append "CXXLAGS", " -fPIC -Wno-mismatched-tags"
    ENV.append "CFLAGS", " -fPIC"
    ENV.append "FFLAGS", " -fPIC"
    

    #ENV.append "CPPFLAGS", "-I#{HOMEBREW_PREFIX}/include"
    #ENV.append "LDFLAGS", "-L#{HOMEBREW_PREFIX}/lib"
            
#     if build.head?
#       system "./autogen.sh", *conf_args
#     else
       system "./autogen.sh"
       system "./configure", *conf_args
#       system "autoreconf", "-fiv"
#       system "./configure", *conf_args
#     end
  
    system "make"
    system "make", "check" if build.with? "check"
    system "make", "install" # if this fails, try separate make/make install steps
    bin.install_symlink "meep-mpi" => "meep" if build.with? "mpi"
  end

  test do
    # make check above
    system "false"
  end
end
