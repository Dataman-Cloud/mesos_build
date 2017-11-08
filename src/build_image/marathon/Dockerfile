FROM demoregistry.dataman-inc.com/library/centos7-base:20160602202509
MAINTAINER prometheus zpang@dataman-inc.com

RUN curl https://bintray.com/sbt/rpm/rpm | tee /etc/yum.repos.d/bintray-sbt-rpm.repo
RUN yum install -y git sbt ruby ruby-devel rpm-build apache-maven python-devel java-1.8.0-openjdk-devel zlib-devel libcurl-devel openssl-devel cyrus-sasl-devel cyrus-sasl-md5 apr-devel subversion-devel apr-util-devel && yum clean all
RUN yum groupinstall -y "Development Tools" && yum clean all
RUN gem install fpm

WORKDIR /data/marathon/
