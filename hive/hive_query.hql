DROP TABLE IF EXISTS rental_stats;

CREATE EXTERNAL TABLE rental_stats (
    car_id STRING,
    rental_year INT,
    total_rentals INT,
    completed_ratio DOUBLE
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/user/hadoop/output/mapreduce_result';

DROP TABLE IF EXISTS cars_raw;

CREATE EXTERNAL TABLE cars_raw (
    car_id STRING,
    make STRING,
    model STRING,
    car_year STRING,
    features STRING,
    category STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
    "separatorChar" = ",",
    "quoteChar" = "\""
)
STORED AS TEXTFILE
LOCATION '/user/hadoop/input/datasource4'
TBLPROPERTIES ("skip.header.line.count"="1");

DROP TABLE IF EXISTS hive_result;

CREATE TABLE hive_result AS
WITH exploded AS (
    SELECT
        c.car_id,
        trim(feature) AS feature,
        r.rental_year,
        r.total_rentals,
        r.completed_ratio
    FROM cars_raw c
    LATERAL VIEW explode(split(c.features, ';')) ft AS feature
    JOIN rental_stats r ON c.car_id = r.car_id
),
grouped AS (
    SELECT
        feature,
        rental_year,
        ROUND(AVG(total_rentals), 2) AS feature_year_avg_rentals,
        ROUND(AVG(completed_ratio), 4) AS feature_year_avg_completed_ratio
    FROM exploded
    GROUP BY feature, rental_year
)
SELECT
    feature,
    rental_year,
    feature_year_avg_rentals,
    feature_year_avg_completed_ratio,
    CASE
        WHEN feature_year_avg_rentals > AVG(feature_year_avg_rentals) OVER (PARTITION BY feature)
        THEN true
        ELSE false
    END AS above_avg_rentals
FROM grouped
ORDER BY feature, rental_year;

SELECT * FROM hive_result LIMIT 30;
