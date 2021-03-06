CREATE EXTERNAL SCHEMA ratings 
from data catalog
database 'ratings'
iam_role '<SUBST-ROLE-ARN>'
CREATE EXTERNAL database IF NOT EXISTS;

CREATE EXTERNAL TABLE ratings.ratings(
  rating int,
  year int,
  title varchar(60),
  company varchar(40))
ROW FORMAT SERDE 
  'org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat'
LOCATION 
  's3://bucket/out/final_data.parquet'
TABLE PROPERTIES 
  ('PARQUET.COMPRESS'='SNAPPY');


CREATE TABLE ratings(
  rating int,
  year int,
  title varchar(60),
  company varchar(40))
  
  SORTKEY AUTO;

CREATE TABLE avg_ratings(
  avg_rating decimal(3,2),
  year int,
  title varchar(60),
  company varchar(40))
  
  SORTKEY AUTO;