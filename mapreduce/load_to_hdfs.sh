#!/bin/bash
set -e

hadoop fs -mkdir -p input/datasource1

DATA_DIR="../zestaw23/input/datasource1"
if [ ! -d "$DATA_DIR" ]; then
    DATA_DIR="./zestaw23/input/datasource1"
fi

hadoop fs -put -f "$DATA_DIR"/rentals*.csv input/datasource1/
hadoop fs -ls input/datasource1 | head -n 10
