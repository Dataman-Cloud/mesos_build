#!/bin/bash
set -e
OPTS='--no-cache'
MESOS_REPO="https://git-wip-us.apache.org/repos/asf/mesos.git"
MESOS_VERSION="1.0.1"
MESOS_BUILD_VERSION="0.2"
MARATHON_REPO="https://github.com/Dataman-Cloud/marathon.git"
MARATHON_BUILD_VERSION="0.2"
MARATHON_VERSION="v1.1.1-fixhealthcheck-1"
DEMO_REGISTRY="demoregistry.dataman-inc.com"

#https://git-wip-us.apache.org/repos/asf/mesos.git
#https://github.com/pangzheng/mesos.git

build_mesos(){
	sh ./src/mesos_build.sh $MESOS_VERSION $MESOS_BUILD_VERSION $MESOS_REPO
}

build_marathon(){
	sh ./src/marathon_build.sh $MARATHON_VERSION $MARATHON_REPO
}

get_mesos_rpm(){
	if [ ! -f ./src/mesos-deb-packaging/*.rpm ];then
		echo "Mesos rpm package does not exist" ;exit 0
	fi

	if [ -f ./base/mesos.rpm ];then
		rm -Rf mesos.rpm
	fi
		cp ./src/mesos-deb-packaging/*.rpm ./base/mesos.rpm
}

get_marathon_rpm(){
	if [ ! -f ./src/marathon-pkg/*.el7.x86_64.rpm ];then
		echo "Marathon rpm package does not exist" ;exit 0
	fi

	if [ -f ./marathon/marathon.rpm ];then
		rm -Rf marathon.rpm
	fi
		cp ./src/marathon-pkg/*.el7.x86_64.rpm ./marathon/marathon.rpm
}

change_registry_tag(){
	IMAGE="$1"	
	docker tag  $IMAGE $DEMO_REGISTRY/$IMAGE
}

push_registry_img(){
	IMAGE="$1"	
	docker push $DEMO_REGISTRY/$IMAGE
}

delete_img(){
	IMAGE="$1"	
        docker rmi $DEMO_REGISTRY/$IMAGE
}

update_images(){
	IMAGE="$1"
	delete_img $IMAGE
	change_registry_tag $IMAGE
	push_registry_img $IMAGE
}

build_base_images(){
	if [ x"$1" == x"base" ];then
                BASE_DIR="base"
        fi
        if [ x"$1" == x"master" ];then
                BASE_DIR="master"
        fi
        if [ x"$1" == x"slave" ];then
                BASE_DIR="slave"
        fi
        if [ x"$1" == x"marathon" ];then
                BASE_DIR="marathon"
        fi
        if [ -f $BASE_DIR/Dockerfile ];then
                rm -rf $BASE_DIR/Dockerfile
        fi
        cp $BASE_DIR/Dockerfile_tmpl $BASE_DIR/Dockerfile && \

        sed -i 's#{{mesos_version}}#'$MESOS_VERSION-$MESOS_BUILD_VERSION'#g' $BASE_DIR/Dockerfile && \

        if [ "$1" = "marathon" ];then
                MARATHON_IMAGE="library/centos7-mesos-$MESOS_VERSION-$MESOS_BUILD_VERSION-marathon:$MARATHON_VERSION-$MARATHON_BUILD_VERSION"
                sed -i 's#{{marathon_version}}#'$MARATHON_VERSION'#g' $BASE_DIR/Dockerfile && \
                docker build $opts -t $MARATHON_IMAGE $BASE_DIR/. && \
                update_images $MARATHON_IMAGE
        else
                MESOS_IMAGE="library/centos7-mesos-$1:$MESOS_VERSION-$MESOS_BUILD_VERSION"
                docker build $OPTS -t $MESOS_IMAGE $BASE_DIR/. && \
                update_images $MESOS_IMAGE
        fi
        rm -Rf $BASE_DIR/Dockerfile
}

build_mesos_image(){
	build_mesos && \
	get_mesos_rpm && \
        build_base_images base && \
        build_base_images master && \
        build_base_images slave
}

build_marathon_image(){
	build_marathon && \
	get_marathon_rpm && \
        build_base_images marathon
}

main(){
	#build_mesos_image && \
	build_marathon_image
}

main
