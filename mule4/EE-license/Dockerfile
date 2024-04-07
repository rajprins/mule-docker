FROM         azul/zulu-openjdk
MAINTAINER   Roy Prins <rajprins@gmail.com>


#--- Define environment variables
ARG         RUNTIME_VERSION
ARG         USERNAME
ARG         PASSWORD

ENV         MULE_HOME=/opt/mule
ENV         DOWNLOAD_URL=https://repository-master.mulesoft.org/nexus/content/repositories/ci-releases/com/mulesoft/mule/distributions/mule-ee-distribution-standalone/${RUNTIME_VERSION}/mule-ee-distribution-standalone-${RUNTIME_VERSION}.zip


#--- Install necessary system tools
RUN         apt-get update && \
            apt-get install -y curl wget unzip vim && \
            rm -rf /var/lib/apt/lists/* && \
            apt-get autoclean


#--- Download and install Mule runtime
WORKDIR     /opt
RUN         curl -u ${USERNAME}:${PASSWORD} ${DOWNLOAD_URL} -o runtime.zip && \
            unzip runtime.zip && \
            rm runtime.zip && \
            mv /opt/mule-enterprise-standalone-${RUNTIME_VERSION} /opt/mule


#--- Define mount points
VOLUME      ["/opt/mule/logs", "/opt/mule/apps", "/opt/mule/domains", "/opt/mule/conf"]


#--- Copy and install License file
COPY        ./resources/license.lic /opt/mule/conf/
RUN         /opt/mule/bin/mule -installLicense /opt/mule/conf/license.lic


#--- Expose the necessary port ranges as required by the Mule Apps
#    HTTP listener default ports, remote debugger, JMX, MMC agent, AMC agent
EXPOSE      8081-8082 5000 1098 7777 9997


#--- Start Mule runtime
WORKDIR     /opt/mule
CMD         ["/opt/bin/mule"]

