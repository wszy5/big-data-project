#!/bin/bash
set -e

chmod +x load_cars_to_hdfs.sh
./load_cars_to_hdfs.sh

beeline -u jdbc:hive2://localhost:10000 -n hadoop -f hive_query.hql

echo ""
echo "=== WYNIKI HIVE ==="
beeline -u jdbc:hive2://localhost:10000 -n hadoop --silent=true -e "SELECT * FROM hive_result LIMIT 30;"

mkdir -p result
beeline -u jdbc:hive2://localhost:10000 -n hadoop --silent=true --outputformat=csv2 -e "SELECT * FROM hive_result;" > result/hive_output.csv
echo "Wynik zapisany do result/hive_output.csv"
