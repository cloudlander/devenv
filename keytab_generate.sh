#!/bin/bash

chkFile()
{
        if [ ! -e $1 ]; then
                echo "$1 doesn't exist!"
                exit 1
        fi

        if [ ! -f $1 ]; then
                echo "$1 is not a regular file!"
                exit 1
        fi
}
KEYTABGEN_HOME=$( dirname $0 )
KEYTABGEN_HOME=$( cd $KEYTABGEN_HOME; pwd )
nodeFile=$KEYTABGEN_HOME/nodes

str="host hdfs mapred hive hbase zookeeper"
array=($str)
length=${#array[@]}

chkFile $nodeFile

nodes=$( cat $nodeFile )

for node in $nodes
do 
   mkdir $node
   echo "addprinc host hdfs mapred hive hbase zookeeper---------"
    for((i=0;i<$length;i++))
    do
       kadmin -w 123456 -p kadmin/admin -q "addprinc -randkey ${array[$i]}/$node@NOVALOCAL"
       kadmin -w 123456 -p kadmin/admin -q "addprinc -randkey ${array[$i]}/$node.novalocal@NOVALOCAL"
    done
   
   echo "generate keytab for  mapred hive hbase zookeeper---------"
   for((i=1;i<$length;i++))
    do
        kadmin -w 123456 -p kadmin/admin -q  "xst -k $node/${array[$i]}-$node.keytab ${array[$i]}/$node@NOVALOCAL ${array[$i]}/$node.novalocal@NOVALOCAL"
    done
   kadmin -w 123456 -p kadmin/admin -q  "xst -k $node/hdfs-$node.keytab hdfs/$node@NOVALOCAL host/$node@NOVALOCAL ${array[$i]}/$node.novalocal@NOVALOCAL"
done

echo "generate complete!--------------------------------"
