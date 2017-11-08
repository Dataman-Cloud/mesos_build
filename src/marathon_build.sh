#!/bin/bash
set -e
BASE_DIR=$(cd `dirname $0` && pwd)
cd $BASE_DIR
MARATHON_VERSION=$1
MARATHON_REPO=${2:-https://github.com/mesosphere/marathon.git}
get_marathon_pkg(){
        if [ -d ./marathon-pkg ];then
        	rm -Rf ./marathon-pkg
        fi
	git clone https://github.com/mesosphere/marathon-pkg.git
}

get_marathon(){
	cd ./marathon-pkg && \
	git clone $MARATHON_REPO && \
	cd marathon
	git checkout $MARATHON_VERSION
	cd .. && \
	git submodule init && \
	git submodule update
}

build_marathon(){
	DOCKERISEXIST=$(docker ps -a | grep build_marathon | wc -l)
        if [  $DOCKERISEXIST -ne 0 ];then
        	docker rm -f build_marathon
        fi

        docker run -it --name build_marathon \
                -v `pwd`/marathon-pkg:/data/marathon \
		-v `pwd`/sbt:/root/.sbt \
                demoregistry.dataman-inc.com/library/centos7-build-marathon \
		make el	
}

main(){
        #get_marathon_pkg
	#get_marathon
        build_marathon
}

main
