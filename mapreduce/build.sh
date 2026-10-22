#!/bin/bash
set -e

mkdir -p bin

HADOOP_CP=$(hadoop classpath)
javac -classpath "${HADOOP_CP}" -d bin src/main/java/mapreduce/*.java

jar -cvfe rental-stats.jar mapreduce.RentalStatsDriver -C bin/ .
