#!/bin/bash
set -e

chmod +x build.sh load_to_hdfs.sh run.sh show_results.sh

./build.sh
./load_to_hdfs.sh
./run.sh
./show_results.sh
