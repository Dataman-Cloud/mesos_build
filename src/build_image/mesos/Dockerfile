FROM demoregistry.dataman-inc.com/library/centos7-base:20160602202509 
MAINTAINER prometheus zpang@dataman-inc.com

# Install a few utility tools
RUN yum install -y tar wget git &&  yum clean all

# Fetch the Apache Maven repo file.
RUN wget http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo

# Install the EPEL repo 
RUN yum install -y epel-release  && yum clean all

# Create a WANdisco SVN repo file to install the correct version:
ADD repo /etc/yum.repos.d/wandisco-svn.repo

# Parts of Mesos require systemd in order to operate. However, Mesos
# only supports versions of systemd that contain the 'Delegate' flag.
# This flag was first introduced in 'systemd version 218', which is
# lower than the default version installed by centos. Luckily, centos
# 7.1 has a patched 'systemd < 218' that contains the 'Delegate' flag.
# Explicity update systemd to this patched version.
  
RUN yum update systemd && yum clean all

# Install essential development tools.

RUN yum groupinstall -y "Development Tools" && yum clean all

# Install other Mesos dependencies.
  
RUN yum install -y apache-maven python-devel java-1.8.0-openjdk-devel zlib-devel libcurl-devel openssl-devel cyrus-sasl-devel cyrus-sasl-md5 apr-devel subversion-devel apr-util-devel && yum clean all

RUN echo 'export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk' >> ~/.bash_profile

# build package tools
# install gems
  
RUN yum install -y ruby ruby-devel ruby-rdoc rubygems rpm-build python-pip && yum clean all && \
	gem install fpm && \
  	gem install json_pure && \
	echo 'export MAINTAINER="system@dataman-inc.com"' >> ~/.bash_profile

RUN mkdir -p /data/ && \
	cd /data/ && \
  	git clone https://github.com/mesosphere/mesos-deb-packaging.git

WORKDIR /data/mesos-deb-packaging
