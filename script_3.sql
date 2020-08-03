/*ѕодсчет кол-ва строк в таблице*/

SELECT 
COUNT(*) AS TOTALROWS
FROM hive_db_student6_1_y.CAvideos;

/*—оздать EXTERNAL таблицы внутри базы данных с использованием всех загруженных файлов*/
/*ќдин файл Ц одна таблица*/

-- EXTERNAL
create external table hive_db_student6_1_y.GBvideos_ext
(
video_id string,
trending_date string,
title string,
channel_title string,
category_id string,
publish_time string,
tags string,
views int,
likes int,
dislikes int,
comment_count int,
thumbnail_link string,
comments_disabled string,
ratings_disabled string,
video_error_or_removed string,
description string
)

ROW FORMAT SERDE 
    'org.apache.hadoop.hive.serde2.OpenCSVSerde'
STORED AS INPUTFORMAT
    'org.apache.hadoop.mapred.TextInputFormat'
OUTPUTFORMAT
    'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
TBLPROPERTIES (
    'serialization.null.format' = '',
    'skip.header.line.count' = '1')
;
LOAD DATA INPATH '/test1_Kruglikov/GBvideos.csv' INTO TABLE hive_db_student6_1_y.GBvideos_ext
;

/*—делать любой отчет по загруженным данным использу€ групповые и агрегатные функции*/

SELECT COUNT(*) 
FROM hive_db_student6_1_y.RUvideos_ext;

SELECT SUM(likes)
FROM ive_db_student6_1_y.RUvideos_ext;






