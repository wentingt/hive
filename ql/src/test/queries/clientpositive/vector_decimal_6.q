set hive.mapred.mode=nonstrict;
SET hive.vectorized.execution.enabled=true;
set hive.fetch.task.conversion=none;

DROP TABLE IF EXISTS DECIMAL_6_1_txt;
DROP TABLE IF EXISTS DECIMAL_6_1;
DROP TABLE IF EXISTS DECIMAL_6_2_txt;
DROP TABLE IF EXISTS DECIMAL_6_2;
DROP TABLE IF EXISTS DECIMAL_6_3_txt;
DROP TABLE IF EXISTS DECIMAL_6_3;

CREATE TABLE DECIMAL_6_1_txt(key decimal(10,5), value int)
ROW FORMAT DELIMITED
   FIELDS TERMINATED BY ' '
STORED AS TEXTFILE;

CREATE TABLE DECIMAL_6_2_txt(key decimal(17,4), value int)
ROW FORMAT DELIMITED
   FIELDS TERMINATED BY ' '
STORED AS TEXTFILE;

LOAD DATA LOCAL INPATH '../../data/files/kv9.txt' INTO TABLE DECIMAL_6_1_txt;
LOAD DATA LOCAL INPATH '../../data/files/kv9.txt' INTO TABLE DECIMAL_6_2_txt;

CREATE TABLE DECIMAL_6_1(key decimal(10,5), value int)
STORED AS ORC;

CREATE TABLE DECIMAL_6_2(key decimal(17,4), value int)
STORED AS ORC;

INSERT OVERWRITE TABLE DECIMAL_6_1 SELECT * FROM DECIMAL_6_1_txt;
INSERT OVERWRITE TABLE DECIMAL_6_2 SELECT * FROM DECIMAL_6_2_txt;

EXPLAIN VECTORIZATION DETAIL
SELECT * FROM DECIMAL_6_1 ORDER BY key, value;
SELECT * FROM DECIMAL_6_1 ORDER BY key, value;

EXPLAIN VECTORIZATION DETAIL
SELECT * FROM DECIMAL_6_2 ORDER BY key, value;
SELECT * FROM DECIMAL_6_2 ORDER BY key, value;

EXPLAIN VECTORIZATION DETAIL
SELECT T.key from (
  SELECT key, value from DECIMAL_6_1
  UNION ALL
  SELECT key, value from DECIMAL_6_2
) T order by T.key;
SELECT T.key from (
  SELECT key, value from DECIMAL_6_1
  UNION ALL
  SELECT key, value from DECIMAL_6_2
) T order by T.key;

EXPLAIN VECTORIZATION DETAIL
CREATE TABLE DECIMAL_6_3 STORED AS ORC AS SELECT key + 5.5 AS k, value * 11 AS v from DECIMAL_6_1 ORDER BY v;
CREATE TABLE DECIMAL_6_3 STORED AS ORC AS SELECT key + 5.5 AS k, value * 11 AS v from DECIMAL_6_1 ORDER BY v;

desc DECIMAL_6_3;

SELECT * FROM DECIMAL_6_3 ORDER BY k, v;

