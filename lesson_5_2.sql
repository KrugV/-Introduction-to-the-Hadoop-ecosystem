/*2. Создать любой Flume поток используя Flume сервис соотвествующего номера.*/

/*Тип источника источник – exeс*/
/*Тип канала – file*/
/*Тип слива – hdfs*/

/*Для сервиса Flume-7 зададим конфиг:*/

```
# Naming the components on the current agent
LoggerAgent.sources = ExecSource
LoggerAgent.channels = FileChannel
LoggerAgent.sinks = HdfsSink

# Describing/Configuring the source
LoggerAgent.sources.ExecSource.type = exec
LoggerAgent.sources.ExecSource.command = tail -F /var/log/hadoop-httpfs/hadoop-cmf-hdfs-HTTPFS-node2.novalocal.log.out
LoggerAgent.sources.ExecSource.interceptors = TimestampInterceptor
LoggerAgent.sources.ExecSource.interceptors.TimestampInterceptor.type = timestamp

# Describing/Configuring the HDFS sink
LoggerAgent.sinks.HdfsSink.type = hdfs
LoggerAgent.sinks.HdfsSink.hdfs.path = /flume/flume-7/exec-file-hdfs-v4/%y-%m-%d/
LoggerAgent.sinks.HdfsSink.hdfs.filePrefix = events

# Describing/Configuring the channel
LoggerAgent.channels.FileChannel.type = file
LoggerAgent.channels.FileChannel.checkpointDir = /tmp/flume-7/checkpoint
LoggerAgent.channels.FileChannel.dataDirs = /tmp/flume-7/data

# Bind the source and sink to the channel
LoggerAgent.sources.ExecSource.channels = FileChannel
LoggerAgent.sinks.HdfsSink.channel = FileChannel
```

/*Источник читиает файл логов инстанса HttpFS сервиса HDFS. Инстанс запущен на том же узле что и наш Flume-7 (node2.novalocal)*/

/*Смотрим, как создались файлы:*/

```
[student6_1@manager ~]$ hdfs dfs -ls -R /flume/flume-7/exec-file-hdfs-v4/
drwxr-xr-x   - flume flume          0 2020-08-23 19:21 /flume/flume-7/exec-file-hdfs-v4/20-08-23
-rw-r--r--   3 flume flume       1088 2020-08-23 19:21 /flume/flume-7/exec-file-hdfs-v4/20-08-23/events.1587324059157
```

/*Смотрим содержимое файла*/

```
[student6_1@manager ~]$ hdfs dfs -cat /flume/flume-7/exec-file-hdfs-v4/20-08-23/events.1587324059157
SEQ!org.apache.hadoop.io.LongWritable"org.apache.hadoop.io.BytesWritable�����I
                                                                              zX�#"9�Eq���_G
2020-08-23 18:29:55,085 INFO httpfsaudit: [/user/student6_1] filter [-]q���_1
2020-08-23 18:29:55,098 INFO httpfsaudit: [/user]q���_<
2020-08-23 18:29:55,116 INFO httpfsaudit: [/user/student6_1]q���_*
2020-08-23 18:29:55,129 INFO httpfsaudit: q���_<
2020-08-23 18:29:55,138 INFO httpfsaudit: [/user/student6_1q���_
2020-08-23 18:29:55,149 WARN org.apache.hadoop.security.UserGroupInformation: PriviledgedActionException as:student6_1 (auth:PROXY) via httpfs (auth:SIMPLE) cause:java.io.FileNotFoundException: File does not exist: /user/student6_1/.Trash/Current/user/student6_1q���_*
2020-08-23 18:29:55,158 INFO httpfsaudit: q���_<
2020-08-23 18:29:55,167 INFO httpfsaudit: [/user/student6_1]q���_C
2020-08-23 18:29:55,177 INFO httpfsaudit: [/user/student6_1/.Trash]q���_<
2020-08-23 18:29:55,190 INFO httpfsaudit: [/user/student6_1]���������I
                                                                                                                                              zX�#"9�E[
```