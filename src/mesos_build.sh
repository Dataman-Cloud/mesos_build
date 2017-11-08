#!/bin/bash
set -e
BASE_DIR=$(cd `dirname $0` && pwd)
cd $BASE_DIR
MESOS_VERSION=$1
BUILD_VERSION=$2
MESOS_REPO=${3:-https://git-wip-us.apache.org/repos/asf/mesos.git}
get_mesos(){
	if [ -d ./mesos ];then
		rm -Rf ./mesos
	fi
	git clone $MESOS_REPO 
}

get_mesos_package(){
	if [ -d ./mesos-deb-packaging ];then
		rm -Rf ./mesos-deb-packaging
	fi
	git clone https://github.com/mesosphere/mesos-deb-packaging.git
}

build_mesos(){
	DOCKERISEXIST=$(docker ps -a | grep build_mesos | wc -l)
	if [  $DOCKERISEXIST -ne 0 ];then 
		docker rm -f build_mesos
	fi
	docker run -it --name build_mesos \
		-e JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk \
 		-e MAKEFLAGS=-j8 \
 		-v `pwd`/mesos:/data/mesos_test/mesos \
		-v `pwd`/mesos-deb-packaging:/data/mesos-deb-packaging \
		-v `pwd`/m2:/root/.m2 \
      		demoregistry.dataman-inc.com/library/centos7-build-mesos:20170325 \
      			./build_mesos \
	  		--src-dir /data/mesos_test/mesos \
          		--repo $MESOS_REPO?ref=$MESOS_VERSION \
          		--nominal-version $MESOS_VERSION \
	  		--rename \
          		--build-version $BUILD_VERSION
}

main(){
	get_mesos
	get_mesos_package
	build_mesos
}

main
