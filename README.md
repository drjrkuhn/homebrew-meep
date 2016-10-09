homebrew-meep
==============

A small tap for the [Homebrew project](http://mxcl.github.com/homebrew/) to install [Meep](http://ab-initio.mit.edu/wiki/index.php/Meep) and its dependencies.

**Be sure to run the following before attempting to install meep, especially if you recently upgraded OS-X (aka macOS):**

```bash
$ xcode-select --install
```


Installation instructions for meep and its dependencies. The MPI version is built by default:

```bash
$ brew update
$ brew tap drjrkuhn/homebrew-meep
$ brew install meep
```

This `meep` formula should automatically install all of its dependencies. Optionally, you may install libctl, harminv, and mpb seperately.

The installation of meep may take some time because it runs all of the tests (including a patched symmetry test). To disable the tests, use `brew install --without-check meep`. To hide the test output, build with the `brew install --without-verbose-check meep`.

To see what other installation options are available, use:

```bash
$ brew tap drjrkuhn/homebrew-meep
$ brew options harminv
$ brew options mpb
$ brew options meep
```

> ~~NOTE: The [github repository for meep](https://github.com/stevengj/meep) does not build yet. The current meep formula relies on the tagged version available from the [Meep download site](http://ab-initio.mit.edu/wiki/index.php/Meep_download). Similarly, `mpb` clones its version from the ab-initio [`mpb` download site](http://ab-initio.mit.edu/wiki/index.php/MIT_Photonic_Bands#MPB_download). The tagged `harminv` is cloned directly from github~~ 

## TODO
- [x] build github version of all dependencies
- [x] get meep and all dependencies to build properly
  - [x] using gsed instead of sed fixed most of the swig problems
- [x] get tests to run properly
  - [x] fix symmetry test (increased epsilon to get it to pass)
- [x] build with LLVM instead of gcc
- [x] build MPI version
- [x] build shared libraries
- [ ] **get guile to work properly on example files without crashing!**
- [ ] get python-meep to work
