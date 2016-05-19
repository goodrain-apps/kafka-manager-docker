FROM anapsix/alpine-java:jdk8
# inpired by: https://github.com/prabhuinbarajan/kafka-manager-docker/

MAINTAINER zhouyq <zhouyq@goodrain.com>

ENV JAVA_MAJOR=8
ENV JAVA_UPDATE=77
ENV JAVA_BUILD=03

ENV JAVA_HOME=/opt/jdk1.${JAVA_MAJOR}.0_${JAVA_UPDATE}
ENV KM_VERSION=1.3.0.8
ENV KM_REVISION=6e196ea7a332471bead747535f9676f0a2bad008
ENV KM_DIR=/kafka-manager-${KM_VERSION}
ENV KM_CFG="${KM_DIR}/conf/application.conf"

# timezone
RUN apk add --no-cache tzdata && \
       cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
       echo "Asia/Shanghai" >  /etc/timezone && \
       date && apk del --no-cache tzdata

# add bash and git
RUN apk add --no-cache bash git && \
    sed -i -e "s/bin\/ash/bin\/bash/" /etc/passwd
    
RUN mkdir -p /tmp && \
    cd /tmp && \
    git clone https://github.com/yahoo/kafka-manager && \
    cd /tmp/kafka-manager && \
    git checkout ${KM_REVISION} && \
    echo 'scalacOptions ++= Seq("-Xmax-classfile-name", "200")' >> build.sbt && \
    ./sbt clean dist

RUN cd /tmp/kafka-manager && \
    unzip  -d / ./target/universal/kafka-manager-${KM_VERSION}.zip && \
    rm -fr /tmp/* /root/.sbt /root/.ivy2 && \
    rm -fr $KM_DIR/share

RUN apk add --no-cache wget curl netcat-openbsd && apk del git tzdata

ADD docker-entrypoint.sh /usr/bin/

RUN chmod +x /usr/bin/docker-entrypoint.sh 

WORKDIR $KM_DIR

EXPOSE 9000

ENTRYPOINT ["docker-entrypoint.sh"]
