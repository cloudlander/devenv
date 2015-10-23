export ICC_HOME=/opt/intel/composer_xe_2013.5.192/bin/intel64
export VTUNE_HOME=/opt/intel/vtune_amplifier_xe_2013
export ZINC_HOME=/data/build_tools/zinc

export HADOOP_DEVEL_BASE=/data/hadoop-devel

export HADOOP_BASE_DIR=${HADOOP_DEVEL_BASE}/hadoop
export HADOOP_LOG_DIR=${HADOOP_DEVEL_BASE}/logs
export HADOOP_PID_DIR=${HADOOP_BASE_DIR}
export HADOOP_CONF_DIR=${HADOOP_DEVEL_BASE}/conf
export HADOOP_HOME=${HADOOP_BASE_DIR}
export HADOOP_COMMON_HOME=${HADOOP_BASE_DIR}
export HADOOP_HDFS_HOME=${HADOOP_COMMON_HOME}
export HADOOP_MAPRED_HOME=${HADOOP_COMMON_HOME}
export HADOOP_YARN_HOME=${HADOOP_COMMON_HOME}
export YARN_LOG_DIR=${HADOOP_LOG_DIR}/yarn

export HIVE_HOME=${HADOOP_DEVEL_BASE}/hive-spark
export HIVE_CONF_DIR=${HADOOP_DEVEL_BASE}/conf

export ZOOKEEPER_HOME=${HADOOP_DEVEL_BASE}/zookeeper
export ZOOCFGDIR=${HADOOP_DEVEL_BASE}/conf

export HBASE_HOME=${HADOOP_DEVEL_BASE}/hbase
export HBASE_CONF_DIR=${HADOOP_DEVEL_BASE}/conf
export HBASE_LOG_DIR=${HADOOP_DEVEL_BASE}/logs/hbase
export HBASE_PID_DIR=${HBASE_HOME}

export SPARK_HOME=/data/sources/spark
export SPARK_CONF_DIR=${HADOOP_DEVEL_BASE}/conf

export MAHOUT_HOME=/data/sources/mahout/distribution/target/mahout-distribution-1.0-SNAPSHOT/mahout-distribution-1.0-SNAPSHOT

export KAFKA_HOME=/data/sources/kafka

export HADOOP_USER_CLASSPATH_FIRST=true

export GEARPUMP_HOME=/data/sources/gearpump/output/target/pack

export IMPALA_HOME=/data/sources/Impala
export BOOST_LIBRARYDIR=/usr/lib/x86_64-linux-gnu
export LD_LIBRARY_PATH=$BOOST_LIBRARYDIR:$LD_LIBRARY_PATH
export LLVM_INCLUDE_DIR=/usr/local/include
export LLVM_LIBRARY_DIR=/usr/local/lib

export LC_ALL="en_US.UTF-8"

#Finally update your PATH
#export PATH=${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin:${HADOOP_HOME}/libexec:${HIVE_HOME}/bin:${ZOOKEEPER_HOME}/bin:${HBASE_HOME}/bin:${SPARK_HOME}/bin:${SPARK_HOME}/sbin:${MAHOUT_HOME}/bin:${KAFKA_HOME}/bin:${ZINC_HOME}/bin:${ICC_HOME}:${VTUNE_HOME}/bin64:$GEARPUMP_HOME/bin:$IMPALA_HOME/bin:/data/dev_tools/clion-1.0.3/bin/cmake/bin/:${PATH}
export PATH=${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin:${HADOOP_HOME}/libexec:${HIVE_HOME}/bin:${ZOOKEEPER_HOME}/bin:${HBASE_HOME}/bin:${SPARK_HOME}/bin:${SPARK_HOME}/sbin:${MAHOUT_HOME}/bin:${KAFKA_HOME}/bin:${ZINC_HOME}/bin:${ICC_HOME}:${VTUNE_HOME}/bin64:$GEARPUMP_HOME/bin:$IMPALA_HOME/bin:${PATH}

function start_hadoop(){
start-all.sh && mr-jobhistory-daemon.sh start historyserver
}

function stop_hadoop(){
mr-jobhistory-daemon.sh stop historyserver &&  stop-all.sh 
}

function restart_yarn(){
mr-jobhistory-daemon.sh stop historyserver
stop-yarn.sh
start-yarn.sh
mr-jobhistory-daemon.sh start historyserver
}

function start_hive(){
hive --service hiveserver2 --hiveconf hive.log.file=hiveserver2.log &
hive --service metastore --hiveconf hive.log.file=metastore.log &
}

function stop_hive(){
kill -9 `ps -ef|grep java|grep hive.metastore|awk -F' ' '{print $2}'`
kill -9 `ps -ef|grep java|grep hive.service|awk -F' ' '{print $2}'`
}

function start_spark(){
start-master.sh && start-slaves.sh && start-history-server.sh
}

function stop_spark(){
stop-history-server.sh && stop-slaves.sh && stop-master.sh
}

function start_kafka(){
kafka-server-start.sh ${KAFKA_HOME}/config/server.properties &
}

function stop_kafka(){
kafka-server-stop.sh ${KAFKA_HOME}/config/server.properties &
}

function start_impala(){
$IMPALA_HOME/bin/start-catalogd.sh -build_type=release&
$IMPALA_HOME/bin/start-statestored.sh -build_type=release&
$IMPALA_HOME/bin/start-impalad.sh -build_type=release&
}

function stop_impala(){
kill -9 `ps -ef|grep Impala|grep catalogd|awk -F' ' '{print $2}'`
kill -9 `ps -ef|grep Impala|grep statestored|awk -F' ' '{print $2}'`
kill -9 `ps -ef|grep Impala|grep impalad|awk -F' ' '{print $2}'`
}
