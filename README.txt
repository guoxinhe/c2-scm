

Makefile interface:
---------------------------------
    the Makefile include 7 standard build operations and some other help ops.
    using >>>make lsop <<< to list them:
        src_get src_package src_install src_config src_build bin_package
        bin_install test clean help

             src_package     src_config      bin_package
     src_get    |   src_install |   src_build   |   bin_install
        |       |       |       |       |       |       |
    +-------------------------------------------------------+
    |   1   |   2   |   3   |   4   |   5   |   6   |   7   |
    +-------------------------------------------------------+
       | |   | | | |   | |                     | |     | |
       | |   | | | |   | |                     | |     | |
       | |   | | | |   | |                     | |     | |
       |_|   |_| |_|   |_|                     |_|     |_|
        |     |   |     |                       |       `--install/usr/xxx
      source  |   |     |                       `--deploy/**xxx.bin.tar.gz
              |   |     `--build/build_xxx/
              |   `--deploy/**xxx.src.tar.gz
              `--temp/src_xxx

    the help ops of makefile:
        clean_xxx help_xxx test_xxx
        sdk_folders lsmod lsop lstest lsall lsmk lsvar lsvars $(varlist) help
    
    the $(varlist):
        supported varlist return variable's value.

    feature:
        local include file support
        full self-set envs, does not need the help of build script

newbuild.sh feature:
---------------------------------
    >>> sticked top, work folder
    >>> lock and auto unlock job
    >>> multi-server for upload web,log, package
    >>> multi-repo/git project union-build
    >>> checkout-tag support, do not need tag the whole software
    >>> log system, to multi-server
    >>> web report on module level progress, to multi-server
    >>> package upload to multi-server
    >>> email, with detail parse break build info, urls
    >>> 7 step Makefile support
    >>> CONFIG_ and command line parse
    >>> Time stamp support

