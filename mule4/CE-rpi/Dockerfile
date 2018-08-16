FROM        resin/rpi-raspbian:stretch
MAINTAINER  Roy Prins <rajprins@gmail.com>

# Define environment variables
ARG         RUNTIME_VERSION
ENV         MULE_HOME /opt/mule
ENV         JAVA_HOME /usr/lib/jvm/java-8-oracle

RUN         apt-get update && \
            apt-get install --no-install-recommends --yes apt-utils wget unzip elfutils oracle-java8-jdk && \
            rm -rf /var/lib/apt/lists/* && \
            apt-get autoclean

# Download and install Mule runtime
WORKDIR     /opt
RUN         wget https://repository-master.mulesoft.org/nexus/content/repositories/releases/org/mule/distributions/mule-standalone/${RUNTIME_VERSION}/mule-standalone-${RUNTIME_VERSION}.tar.gz && \
            tar zxf mule-standalone-${RUNTIME_VERSION}.tar.gz -C /opt/ && \
            rm mule-standalone-${RUNTIME_VERSION}.tar.gz && \
            ln -s /opt/mule-standalone-${RUNTIME_VERSION} /opt/mule

# Copy prepared configuration files and required libraries
COPY        ./resources/wrapper.conf /opt/mule/conf/
COPY        ./resources/mule /opt/mule/bin/
COPY        ./resources/libwrapper.so /opt/mule/lib/boot/libwrapper-linux-armhf-32.so
COPY        ./resources/wrapper.jar /opt/mule/lib/boot/wrapper-3.2.3.jar
COPY        ./resources/wrapper /opt/mule/lib/boot/exec/wrapper-linux-armhf-32

# Define mount points
VOLUME      ["/opt/mule/logs", "/opt/mule/apps", "/opt/mule/domains"]

# Expose the necessary port ranges as required by the Mule Apps
# HTTP listener default ports, remote debugger, JMX, MMC agent, AMC agent
EXPOSE      8081-8082 5000 1098 7777 9997

# Start Mule runtime
WORKDIR     /opt/mule
CMD         ["/opt/mule/bin/mule"]