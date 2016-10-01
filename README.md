homebrew-meep
==============

A small tap for the [Homebrew project](http://mxcl.github.com/homebrew/) to install [Meep](http://ab-initio.mit.edu/wiki/index.php/Meep) and its dependencies Installation instructions:

```bash
$ brew update
$ brew tap drjrkuhn/homebrew-meep
$ brew install meep
```

The `meep` formula should pull its dependencies. Optionally, you may install libctl, harminv, and mpb seperately.

To see what installation options are available, use:

```bash
$ brew options libctl
$ brew options harminv
$ brew options mpb
```

> NOTE: The [github repository for meep](https://github.com/stevengj/meep) does not work yet. The meep formula relies on the tagged version available from the [Meep download site](http://ab-initio.mit.edu/wiki/index.php/Meep_download). `harminv` and `mpb` pull directly from github
