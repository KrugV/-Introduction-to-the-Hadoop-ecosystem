/*1. Модифицировать свой Flume-агент, созданный в предыдущем ДЗ таким образом, чтобы данные попадали в HDFS и Hbase одновременно*/

/*Задаём два канала на два слива с одним источником. По умолчанию параметр */
/*`LoggerAgent.sources.ExecSource.selector.type == replicating`. В этом случае событие будет отправлено на все*/ 
/*указанные каналы. При значении `multiplexing`, событие будет отправлено только в подходящие каналы. Условие */
/*выбора канала задаётся дополнительными параметрами.*/

```
# Naming the components on the current agent
LoggerAgent.sources = ExecSource
LoggerAgent.channels = FileChannelForHdfs FileChannelForHive
LoggerAgent.sinks = HdfsSink HiveSink

# SOURCES

# Describing/Configuring the source
LoggerAgent.sources.ExecSource.type = exec
LoggerAgent.sources.ExecSource.command = tail -F /var/log/hadoop-httpfs/hadoop-cmf-hdfs-HTTPFS-node2.novalocal.log.out
LoggerAgent.sources.ExecSource.interceptors = TimestampInterceptor
LoggerAgent.sources.ExecSource.interceptors.TimestampInterceptor.type = timestamp

# SINKS

# Describing/Configuring the HDFS sink
LoggerAgent.sinks.HdfsSink.type = hdfs
LoggerAgent.sinks.HdfsSink.hdfs.path = /flume/flume-7/exec-file-hdfs-v10/%y-%m-%d/
LoggerAgent.sinks.HdfsSink.hdfs.filePrefix = events

# Describing/Configuring the Hive sink
LoggerAgent.sinks.HiveSink.type = hive
LoggerAgent.sinks.HiveSink.hive.metastore = thrift://89.208.221.132:9083
LoggerAgent.sinks.HiveSink.hive.database = student6_1_les5
LoggerAgent.sinks.HiveSink.hive.table = flume_logger_agent
LoggerAgent.sinks.HiveSink.hive.partition = %y-%m-%d
LoggerAgent.sinks.HiveSink.serializer = DELIMITED
LoggerAgent.sinks.HiveSink.serializer.delimiter = "\t"
LoggerAgent.sinks.HiveSink.serializer.fieldnames = text

# CHANNELS

# Describing/Configuring the channel for hdfs sink
LoggerAgent.channels.FileChannelForHdfs.type = file
LoggerAgent.channels.FileChannelForHdfs.checkpointDir = /tmp/flume-7/checkpoint-hdfs
LoggerAgent.channels.FileChannelForHdfs.dataDirs = /tmp/flume-7/data-hdfs

# Describing/Configuring the channel for hive sink
LoggerAgent.channels.FileChannelForHive.type = file
LoggerAgent.channels.FileChannelForHive.checkpointDir = /tmp/flume-7/checkpoint-hive
LoggerAgent.channels.FileChannelForHive.dataDirs = /tmp/flume-7/data-hive

# BINDING

# Binding source and sinks to channels
LoggerAgent.sources.ExecSource.channels = FileChannelForHdfs FileChannelForHive
LoggerAgent.sinks.HdfsSink.channel = FileChannelForHdfs
LoggerAgent.sinks.HiveSink.channel = FileChannelForHive
```

/*Таблица в hive:*/

```
create table student6_1_les5.flume_logger_agent (
    text string
)
partitioned by (`date` string)
clustered by (text) into 5 buckets
stored as orc;
```

/*Данные логов будут писаться в одну строку, без разделителей.*/

/*Для успешного старта агента так же нужно было указать параметры для `Flume Service Environment`:*/

```
HCAT_HOME=/opt/cloudera/parcels/CDH-5.16.2-1.cdh5.16.2.p0.8/lib/hive-hcatalog
HIVE_HOME=/opt/cloudera/parcels/CDH-5.16.2-1.cdh5.16.2.p0.8/lib/hive
```

/*Результат:*/

```
select * from student6_1_les5.flume_logger_agent limit 8;
```

| flume_logger_agent.text                                                                                                              | flume_logger_agent.date |
| ------------------------------------------------------------------------------------------------------------------------------------ | ----------------------- |
| 2020-08-30 22:17:02,271 INFO httpfsaudit: [/user/flume/student6_1/log/20-08-30/hdfs-st6_1-.1587377562789.gz]                       | 20-08-30                |
| 2020-08-30 22:17:02,530 INFO httpfsaudit: [/user/flume/student6_1/log/20-08-30/hdfs-st6_1-.1587377562789.gz]                       | 20-08-30                |
| 2020-08-30 22:17:02,544 INFO httpfsaudit: [/user/flume/student6_1/log/20-08-30/hdfs-st6_1-.1587377562789.gz]                       | 20-08-30                |
| 2020-08-30 22:17:02,558 INFO httpfsaudit: [/user/flume/student6_1/log/20-08-30/hdfs-st6_1-.1587377562789.gz]                       | 20-08-30                |
| 2020-08-30 22:17:02,569 INFO httpfsaudit: [/user/flume/student6_1/log/20-08-30/hdfs-st6_1-.1587377562789.gz]                       | 20-08-30                |
| 2020-08-30 22:17:02,581 INFO httpfsaudit: [/user/flume/student6_1/log/20-08-30/hdfs-st6_1-.1587377562789.gz]                       | 20-08-30                |
| 2020-08-30 22:17:02,592 INFO httpfsaudit: [/user/flume/student6_1/log/20-08-30/hdfs-st6_1-.1587377562789.gz] offset [0] len [4096] | 20-08-30                |
| 2020-08-30 22:17:02,605 INFO httpfsaudit: [/user/flume/student6_1/log/20-08-30/hdfs-st6_1-.1587377562789.gz]                       | 20-08-30                |

```
[student6_1@manager ~]$ hdfs dfs -ls -R /flume/flume-7/exec-file-hdfs-v10
drwxr-xr-x   - flume flume          0 2020-08-30 22:59 /flume/flume-7/exec-file-hdfs-v10/20-08-30
-rw-r--r--   3 flume flume       1337 2020-08-30 22:59 /flume/flume-7/exec-file-hdfs-v10/20-08-30/events.1587423544595
```

```
[student6_1@manager ~]$ hdfs dfs -cat /flume/flume-7/exec-file-hdfs-v10/20-08-30/events.1587423544595
SEQ!org.apache.hadoop.io.LongWritable"org.apache.hadoop.io.BytesWritable
2020-08-30 22:17:02,271 INFO httpfsaudit: [/user/flume/student6_1/log/20-08-30/hdfs-st6_1-.1587377562789.gz]
2020-08-30 22:17:02,530 INFO httpfsaudit: [/user/flume/student6_1/log/20-08-30/hdfs-st6_1-.1587377562789.gz]
2020-08-30 22:17:02,544 INFO httpfsaudit: [/user/flume/student6_1/log/20-08-30/hdfs-st6_1-.1587377562789.gz]
2020-08-30 22:17:02,558 INFO httpfsaudit: [/user/flume/student6_1/log/20-08-30/hdfs-st6_1-.1587377562789.gz]
2020-08-30 22:17:02,569 INFO httpfsaudit: [/user/flume/student6_1/log/20-08-30/hdfs-st6_1-.1587377562789.gz]
2020-08-30 22:17:02,581 INFO httpfsaudit: [/user/flume/student6_1/log/20-08-30/hdfs-st6_1-.1587377562789.gz]
2020-08-30 22:17:02,592 INFO httpfsaudit: [/user/flume/student6_1/log/20-08-30/hdfs-st6_1-.1587377562789.gz] offset [0] len [4096]
2020-08-30 22:17:02,605 INFO httpfsaudit: [/user/flume/student6_1/log/20-08-30/hdfs-st6_1-.1587377562789.gz]
```