#!/bin/bash

TOPDIR=`pwd`
build_tools_dir="${TOPDIR}/build_tools"
dev_tools_dir="${TOPDIR}/dev_tools"
[[ `grep 'noproxy' ~/.bashrc` ]] || perl -np -e "for(\$_){s|#BUILD_TOOLS#|$build_tools_dir|g;s|#DEV_TOOLS#|$dev_tools_dir|g;}" >> ~/.bashrc <<WHOLEEOF
# User specific aliases and functions
export JAVA8_HOME=#BUILD_TOOLS#/jdk1.8.0_60
export JAVA7_HOME=#BUILD_TOOLS#/jdk1.7.0_45
export JAVA5_HOME=#BUILD_TOOLS#/jdk1.5.0_22
export JAVA_HOME=\$JAVA7_HOME
export ANT_HOME=#BUILD_TOOLS#/ant
export MAVEN_HOME=#BUILD_TOOLS#/maven
export SCALA_HOME=#BUILD_TOOLS#/scala
export SBT_HOME=#BUILD_TOOLS#/sbt
export FORREST_HOME=#BUILD_TOOLS#/apache-forrest-0.9
export FUSE_HOME=#BUILD_TOOLS#/fuse
export GRADLE_HOME=#BUILD_TOOLS#/gradle
export GROOVY_HOME=#BUILD_TOOLS#/groovy

export PROXY_HOST=XX.XX.XX.XX
export PROXY_PORT=XXX
export NOPROXY=XXX

export PATH=\$JAVA_HOME/bin:\$ANT_HOME/bin:\$MAVEN_HOME/bin:\$FORREST_HOME/bin:\$EC2_HOME/bin:\$SCALA_HOME/bin:\$SBT_HOME/bin:\$GRADLE_HOME/bin:\$GROOVY_HOME/bin:#BUILD_TOOLS#/protobuf/bin:\$PATH

umask 022

function eclipse(){
#DEV_TOOLS#/eclipse/eclipse &
}
function idea(){
sh #DEV_TOOLS#/idea/bin/idea.sh &
}
function webstorm(){
sh #DEV_TOOLS#/webstorm/bin/webstorm.sh &
}
function pycharm(){
sh #DEV_TOOLS#/pycharm/bin/pycharm.sh &
}
function setproxy(){
export http_proxy=http://\$PROXY_HOST:\$PROXY_PORT
export https_proxy=http://\$PROXY_HOST:\$PROXY_PORT
export MAVEN_OPTS="-Dhttp.proxyHost=\${PROXY_HOST} -Dhttp.proxyPort=\${PROXY_PORT} -Dhttps.proxyHost=\${PROXY_HOST} -Dhttps.proxyPort=\${PROXY_PORT} -Dhttp.nonProxyHosts=\${NOPROXY} -Dhttps.nonProxyHosts=\${NOPROXY} -Dftp.proxyHost=\${PROXY_HOST} -Dftp.proxyPort=\${PROXY_PORT} -Dftp.nonProxyHosts=\${NOPROXY}"
export ANT_OPTS="-Dhttp.proxyHost=\${PROXY_HOST} -Dhttp.proxyPort=\${PROXY_PORT} -Dhttps.proxyHost=\${PROXY_HOST} -Dhttps.proxyPort=\${PROXY_PORT} -Dhttp.nonProxyHosts=\${NOPROXY} -Dhttps.nonProxyHosts=\${NOPROXY} -Dftp.proxyHost=\${PROXY_HOST} -Dftp.proxyPort=\${PROXY_PORT} -Dftp.nonProxyHosts=\${NOPROXY}"
export GRADLE_OPTS="-Dhttp.proxyHost=\${PROXY_HOST} -Dhttp.proxyPort=\${PROXY_PORT} -Dhttps.proxyHost=\${PROXY_HOST} -Dhttps.proxyPort=\${PROXY_PORT} -Dhttp.nonProxyHosts=\${NOPROXY} -Dhttps.nonProxyHosts=\${NOPROXY} -Dftp.proxyHost=\${PROXY_HOST} -Dftp.proxyPort=\${PROXY_PORT} -Dftp.nonProxyHosts=\${NOPROXY}"
export SBT_OPTS="-Dhttp.proxyHost=\${PROXY_HOST} -Dhttp.proxyPort=\${PROXY_PORT} -Dhttps.proxyHost=\${PROXY_HOST} -Dhttps.proxyPort=\${PROXY_PORT} -Dhttp.nonProxyHosts=\${NOPROXY} -Dhttps.nonProxyHosts=\${NOPROXY} -Dftp.proxyHost=\${PROXY_HOST} -Dftp.proxyPort=\${PROXY_PORT} -Dftp.nonProxyHosts=\${NOPROXY}"
}
function noproxy(){
export http_proxy=
export https_proxy=
export MAVEN_OPTS=
export ANT_OPTS=
export GRADLE_OPTS=
export SBT_OPTS=
}
function showproxy(){
echo "http_proxy=\$http_proxy"
echo "https_proxy=\$https_proxy"
echo "MAVEN_OPTS=\$MAVEN_OPTS"
echo "ANT_OPTS=\$ANT_OPTS"
echo "GRADLE_OPTS=\$GRADLE_OPTS"
echo "SBT_OPTS=\$SBT_OPTS"
}

RServers="node1 node2"
PASSWD=passwd

function do_all(){
for rserver in \$RServers
do
  expect <<EOF
set timeout 3600
set CMD [lindex \$argv 2]
spawn ssh \${rserver} "\$@"
expect "(yes/no)?" {
send "yes\r"
expect "password:"
send "\${PASSWD}\r"
} "password:" {send "\${PASSWD}\r"} "*host " {exit 1}
expect eof
EOF
done
}

function cp_all(){
for rserver in \$RServers
do
  expect <<EOF
set timeout 3600
set CMD [lindex \$argv 2]
spawn scp  "\$1" \${rserver}:"\$1"
expect "(yes/no)?" {
send "yes\r"
expect "password:"
send "\${PASSWD}\r"
} "password:" {send "\${PASSWD}\r"} "*host " {exit 1}
expect eof
EOF
done
}

function do_on(){
server=\$1
shift
for rserver in \$server
do
  expect <<EOF
set timeout 3600
set CMD [lindex \$argv 2]
spawn ssh \${rserver} "\$@"
expect "(yes/no)?" {
send "yes\r"
expect "password:"
send "\${PASSWD}\r"
} "password:" {send "\${PASSWD}\r"} "*host " {exit 1}
expect eof
EOF
done
}

function nopass(){
do_all mkdir ~/.ssh
do_all chmod 700 ~/.ssh
ssh-keygen -q -f ~/.ssh/id_dsa -t dsa -v -N ''
cp ~/.ssh/id_dsa.pub ~/.ssh/authorized_keys
cp_all ~/.ssh/authorized_keys
do_all chmod 600 ~/.ssh/authorized_keys
}

function usejdk8(){
export JAVA_HOME=\$JAVA8_HOME
export PATH=\$JAVA_HOME/bin:\$PATH
}
function usejdk7(){
export JAVA_HOME=\$JAVA7_HOME
export PATH=\$JAVA_HOME/bin:\$PATH
}
export EDITOR=vim
alias wget="wget --no-check-certificate"
WHOLEEOF

#refresh env vars
PS1=notempty . ~/.bashrc
$build_tools_dir/maven/bin/mvn >/dev/null 2>&1
cp $build_tools_dir/settings.xml ~/.m2/

grep "Ubuntu" /etc/issue > /dev/null
if [ $? -eq 0 ]
then
#os tools
#sudo cp ${TOPDIR}/ubuntu/os.list /etc/apt/sources.list.d/
#sudo dpkg -i ${TOPDIR}/ubuntu/*.deb

#required for bigtop
sudo apt-get install -y libxslt1-dev libkrb5-dev libldap2-dev libmysqlclient-dev libsasl2-dev libsqlite3-dev libxml2-dev python-dev python-setuptools liblzo2-dev libzip-dev libfuse-dev libssl-dev build-essential dh-make debhelper devscripts
sudo apt-get install -y sharutils cmake automake autoconf asciidoc python2.7-dev

#required for reprepro
sudo apt-get install -y libgpgme11-dev libbz2-dev libarchive-dev libdb-dev

#required for ADT
sudo apt-get install -y lib32stdc++6 lib32ncurses5 libc6-i386

#general dev tools
sudo apt-get install -y git subversion expect ctags vim ssh patch graphviz dos2unix ruby ruby-dev ruby-mkrf nodejs

#docker
sudo apt-get install docker-io lxc
else
#os tools
if [ ! -f /etc/yum.repos.d/os.repo ]
then
  cd /etc
  #sudo tar zcf yum_repos_orig.tgz yum.repos.d
  #sudo rm -f yum.repos.d/*
  #sudo cp ${TOPDIR}/centos/os.repo yum.repos.d/
fi

#sudo rpm -ivh ${TOPDIR}/centos/*.rpm

#required for bigtop
sudo yum install -y rpm-build fuse fuse-devel cmake redhat-rpm-config openssl-devel autoconf automake gcc-c++ python-devel python-setuptools libxml2-devel libxslt-devel cyrus-sasl-devel sqlite-devel openldap-devel mysql-devel rsync lzo-devel lzo

#general dev tools
sudo yum install -y git subversion vim expect ctags graphviz dos2unix ruby ruby-devel rubygems
fi

#build necessary libraries
#cd $build_tools_dir/protobuf-2.5.0
#./configure --prefix=$build_tools_dir/protobuf
#make install -j4
#cd $build_tools_dir/snappy-1.0.5
#./configure --prefix=/usr
#make -j4
#sudo make install

#customization
cp $dev_tools_dir/vim/vimrc ~/.vimrc
if [ -d /usr/share/vim/vim74 ]
then
  sudo cp $dev_tools_dir/vim/*.vim /usr/share/vim/vim74/plugin/
else
  if [ -d /usr/share/vim/vim73 ]
  then
    sudo cp $dev_tools_dir/vim/*.vim /usr/share/vim/vim73/plugin/
  else
    sudo cp $dev_tools_dir/vim/*.vim /usr/share/vim/vim72/plugin/
  fi
fi
if [ ! -d ~/.ssh ]
then
  mkdir ~/.ssh
  chmod 700 ~/.ssh
fi
cat $dev_tools_dir/ssh/ssh_config >> ~/.ssh/config
cp $dev_tools_dir/ssh/*.key ~/.ssh/

