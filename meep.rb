class Meep < Formula
  desc "Meep (or MEEP) is a free finite-difference time-domain (FDTD) simulation software package developed at MIT to model electromagnetic systems."
  homepage "http://ab-initio.mit.edu/meep/"
  url "https://github.com/stevengj/meep/archive/1.3.tar.gz"
  version "1.3"
  sha256 "562e070a60ca1a0cf0a1e89c07ad2ca40e21b14a7f4ac9c5b7b5e0100cbda714"
  head "https://github.com/stevengj/meep.git"
  
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
  depends_on "gnu-sed" => :build

  option "without-check", "Disable build-time checking (not recommended)"
  option "without-verbose-check", "Disable verbose build-time checking (not recommended)"
  
  mpi_args = [:recommended]
  mpi_args << "with-mpi" if build.with? "mpi"
  
  depends_on "h5utils" => :recommended
  depends_on "swig"
  depends_on "gsl"
  depends_on "hdf5" => mpi_args
  depends_on "fftw" => mpi_args
  depends_on "harminv"
  depends_on "libctl-meep" => :recommended
  depends_on "mpb"
  depends_on "openblas" => :optional

  def install
    # homebrew standard libraries        
    ENV.append "CPLUS_INCLUDE_PATH", "#{HOMEBREW_PREFIX}/include"
    ENV.append "LIBRARY_PATH", "#{HOMEBREW_PREFIX}/lib"

    ## Position Independent Code, needed on 64-bit
    ENV.append "CXXLAGS", " -fPIC -Wno-mismatched-tags"
    ENV.append "CFLAGS", " -fPIC"
    ENV.append "FFLAGS", " -fPIC"

    # default OSX BSD sed does not work. Need to use gnu-sed during make
    inreplace "libctl/Makefile.am", "sed", "gsed"
    inreplace "src/Makefile.am", "sed", "gsed"
    
    # fix symmetry test error by increasing epsilon slightly
    inreplace "tests/symmetry.cpp", "eps_compare = 1e-9;", "eps_compare = 3e-9;"

    conf_args = [
        "--enable-maintainer-mode",
        "--disable-dependency-tracking",
        "--disable-silent-rules",
        "--enable-shared",
        "--prefix=#{prefix}"
      ]
    
    if build.with? "openblas"
      conf_args << "--with-blas=#{Formula["openblas"].opt_prefix}"
      conf_args << "--with-lapack=#{Formula["openblas"].opt_prefix}"
    elsif OS.mac?
      # otherwise, libblas and liblapack should be detected from Accelerator framework
    end

    if build.with? "libctl"    
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
    if build.with? "check"
      ohai "Testing Meep. This could take several minutes."
      ohai "Install using --without-check to skip tests."
      ENV["VERBOSE"] = "true" if build.with? "verbose-check"
      system "make", "check"
      ohai "Testing done."
    end
    bin.install_symlink "meep-mpi" => "meep" if build.with? "mpi"
  end

  test do
    # make check above
    system "false"
  end
end
