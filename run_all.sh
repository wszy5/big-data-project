#!/bin/bash
set -e

cd "$(dirname "$0")"

chmod +x mapreduce/run.sh hive/run.sh

./mapreduce/run.sh
./hive/run.sh
