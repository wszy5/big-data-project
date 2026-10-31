#!/bin/bash
set -e

cd "$(dirname "$0")"

DATA_DIR="../zestaw23/input/datasource4"
if [ ! -d "$DATA_DIR" ]; then
    DATA_DIR="./zestaw23/input/datasource4"
fi

hadoop fs -mkdir -p input/datasource4
if ! hadoop fs -test -e input/datasource4/cars.csv 2>/dev/null; then
    hadoop fs -put -f "$DATA_DIR"/cars.csv input/datasource4/
fi

beeline -u jdbc:hive2://localhost:10000 -n hadoop -f hive_query.hql

mkdir -p result
beeline -u jdbc:hive2://localhost:10000 -n hadoop --silent=true --outputformat=csv2 -e "SELECT * FROM hive_result;" > result/hive_output.csv

head -n 25 result/hive_output.csv
