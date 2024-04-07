FROM         azul/zulu-openjdk
MAINTAINER   Roy Prins <rajprins@gmail.com>


#--- Define environment variables
ARG         RUNTIME_VERSION
ENV         DOWNLOAD_URL=https://repository-master.mulesoft.org/nexus/content/repositories/releases/org/mule/distributions/mule-standalone/${RUNTIME_VERSION}/mule-standalone-${RUNTIME_VERSION}.tar.gz
ENV         MULE_HOME=/opt/mule


#--- Install necessary system tools
RUN         apt-get update && \
            apt-get install -y curl wget unzip vim nano && \
            rm -rf /var/lib/apt/lists/* && \
            apt-get autoclean


#--- Download and install Mule runtime
WORKDIR     /opt
RUN         set -x && \
            wget ${DOWNLOAD_URL} && \
            tar zxf mule-standalone-${RUNTIME_VERSION}.tar.gz -C /opt/ && \
            rm mule-standalone-${RUNTIME_VERSION}.tar.gz && \
            mv /opt/mule-standalone-${RUNTIME_VERSION} /opt/mule


#--- Define mount points
VOLUME      ["/opt/mule/logs", "/opt/mule/conf", "/opt/mule/apps", "/opt/mule/domains"]


#--- Expose the necessary port ranges as required by the Mule Apps
#    HTTP listener default ports, remote debugger, JMX, MMC agent, AMC agent
EXPOSE      8081-8082 5000 1098 7777 9997


#-- Start Mule runtime
WORKDIR     /opt/mule
ENTRYPOINT ["/opt/mule/bin/mule"]
