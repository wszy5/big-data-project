#!/bin/bash
set -e

chmod +x load_cars_to_hdfs.sh run_hive.sh show_results.sh
./run_hive.sh
