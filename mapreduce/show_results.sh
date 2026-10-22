#!/bin/bash

hadoop fs -cat output/mapreduce_result/part-r-* | head -n 25

mkdir -p result
hadoop fs -get -f output/mapreduce_result/part-r-* result/
