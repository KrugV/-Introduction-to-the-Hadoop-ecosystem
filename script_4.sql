/*Есть большая таблица по имени*/


create external table hive_db.citation_data
(
  oci string,
  citing string,
  cited string,
  creation string,
  timespan string,
  journal_sc string,
  author_sc string
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
location '/test_datasets/citation'


/*Её размер вот такой:*/


hdfs dfs -du -h -s /test_datasets/citation
97.2 G 291.5 G /test_datasets/citation


/*1. Создать две таблицы в форматах PARQUET/ORC/AVRO c компрессией и без оной. */

/*Выберем вариант PARQUET с компрессией.*/


-- set parquet.compression=SNAPPY;

create external table citation_data_parquet (
    oci string,
    citing string,
    cited string,
    creation string,
    timespan string,
    journal_sc string,
    author_sc string
)
STORED AS PARQUET
LOCATION '/user/student3_7/citation_data_parquet';


/*2. Заполнить данными из большой таблицы hive_db.citation_data*/


-- set hive.exec.parallel=true;

insert into student6_1_les3.citation_data_parquet
select * from hive_db.citation_data;


/*3. Посмотреть на получившийся размер данных.*/


[student6_1@manager ~]$ hdfs dfs -du -h -s /user/student6_1/citation_data_parquet
22.7 G  68.2 G  /user/student6_1/citation_data_parquet


/*4. Сделать выводы о эффективности хранения и компресии.*/

Объём данных изменился с 97.2 до 22.7 гигабайт. Данные в таблице с форматом PARQUET с сжатием занимают в ~4 раза меньше места чем исходные csv файлы.
