#!/bin/bash
set -e

cd "$(dirname "$0")"

rm -rf bin rental-stats.jar
mkdir -p bin

HADOOP_CP=$(hadoop classpath)
javac -classpath "${HADOOP_CP}" -d bin src/main/java/mapreduce/*.java
jar -cvfe rental-stats.jar mapreduce.RentalStatsDriver -C bin/ .

DATA_DIR="../zestaw23/input/datasource1"
if [ ! -d "$DATA_DIR" ]; then
    DATA_DIR="./zestaw23/input/datasource1"
fi

hadoop fs -mkdir -p input/datasource1
if ! hadoop fs -test -e input/datasource1/rentals00.csv 2>/dev/null; then
    hadoop fs -put -f "$DATA_DIR"/rentals*.csv input/datasource1/
fi

hadoop fs -rm -r -f output/mapreduce_result 2>/dev/null || true
hadoop jar rental-stats.jar input/datasource1 output/mapreduce_result

mkdir -p result
hadoop fs -get -f output/mapreduce_result/part-r-* result/

head -n 20 result/part-r-00000
