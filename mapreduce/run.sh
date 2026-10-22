#!/bin/bash
set -e

if [ ! -f "rental-stats.jar" ]; then
    ./build.sh
fi

hadoop fs -rm -r -f output/mapreduce_result 2>/dev/null || true

hadoop jar rental-stats.jar mapreduce.RentalStatsDriver input/datasource1 output/mapreduce_result

hadoop fs -cat output/mapreduce_result/part-r-* | head -n 15
