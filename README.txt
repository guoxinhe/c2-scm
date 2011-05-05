

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


