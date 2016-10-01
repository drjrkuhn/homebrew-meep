homebrew-meep
==============

A small tap for the [Homebrew project](http://mxcl.github.com/homebrew/) to install [Meep](http://ab-initio.mit.edu/wiki/index.php/Meep) and its dependencies.

Installation instructions:

```bash
$ brew update
$ brew tap drjrkuhn/homebrew-meep
$ brew install meep
```

This `meep` formula should automatically install all of its dependencies. Optionally, you may install libctl, harminv, and mpb seperately.

The installation of meep may take some time because it runs all of the tests (including a patched symmetry test). To disable the tests, use `brew install --without-check meep`.

To see what other installation options are available, use:

```bash
$ brew tap drjrkuhn/homebrew-meep
$ brew options harminv
$ brew options mpb
$ brew options meep
```

> NOTE: The [github repository for meep](https://github.com/stevengj/meep) does not work yet. The meep formula relies on the tagged version available from the [Meep download site](http://ab-initio.mit.edu/wiki/index.php/Meep_download). Similarly, `mpb` clones its version from the ab-initio [`mpb` download site](http://ab-initio.mit.edu/wiki/index.php/MIT_Photonic_Bands#MPB_download). The tagged `harminv` is cloned directly from github 
