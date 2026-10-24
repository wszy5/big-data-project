#!/bin/bash
set -e

hadoop fs -mkdir -p input/datasource4

DATA_DIR="../zestaw23/input/datasource4"
if [ ! -d "$DATA_DIR" ]; then
    DATA_DIR="./zestaw23/input/datasource4"
fi

hadoop fs -put -f "$DATA_DIR"/cars.csv input/datasource4/
hadoop fs -ls input/datasource4
