#!/bin/bash

beeline -u jdbc:hive2://localhost:10000 -n hadoop --silent=true -e "SELECT * FROM hive_result ORDER BY feature, rental_year;"

echo ""
echo "Liczba wierszy:"
beeline -u jdbc:hive2://localhost:10000 -n hadoop --silent=true -e "SELECT COUNT(*) FROM hive_result;"
