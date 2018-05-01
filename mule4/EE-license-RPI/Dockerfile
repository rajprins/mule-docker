FROM        resin/rpi-raspbian:stretch
MAINTAINER  Roy Prins <rajprins@gmail.com>

# Define environment variables
ARG         RUNTIME_VERSION=4.1.1
ARG         WRAPPER_VERSION=3.5.34
ENV         WRAPPER_VERSION $WRAPPER_VERSION
ENV         RUNTIME_VERSION $RUNTIME_VERSION
ENV         MULE_HOME /opt/mule
ENV         JAVA_HOME /usr/lib/jvm/java-8-oracle

RUN         apt-get update && \
            apt-get install --no-install-recommends --yes apt-utils wget unzip elfutils oracle-java8-jdk && \
            rm -rf /var/lib/apt/lists/* && \
            apt-get autoclean

# Download and install Mule runtime
WORKDIR     /opt
RUN         wget https://s3.amazonaws.com/new-mule-artifacts/mule-ee-distribution-standalone-${RUNTIME_VERSION}.zip && \
            unzip mule-ee-distribution-standalone-${RUNTIME_VERSION}.zip -d /opt/ && \
            rm mule-ee-distribution-standalone-${RUNTIME_VERSION}.zip && \
            ln -s /opt/mule-enterprise-standalone-${RUNTIME_VERSION} /opt/mule

# Copy prepared configuration files and required libraries
COPY        ./resources/wrapper.conf /opt/mule/conf/
COPY        ./resources/mule /opt/mule/bin/
COPY        ./resources/libwrapper.so /opt/mule/lib/boot/libwrapper-linux-armhf-32.so
COPY        ./resources/wrapper.jar /opt/mule/lib/boot/wrapper-3.2.3.jar
COPY        ./resources/wrapper /opt/mule/lib/boot/exec/wrapper-linux-armhf-32

# Define mount points
VOLUME      ["/opt/mule/logs", "/opt/mule/apps", "/opt/mule/domains"]

# Copy and install License file
COPY        ./resources/mule-ee-license.lic /opt/mule/conf/
RUN         /opt/mule/bin/mule -installLicense /opt/mule/conf/mule-ee-license.lic

# Expose the necessary port ranges as required by the Mule Apps
# HTTP listener default ports, remote debugger, JMX, MMC agent, AMC agent
EXPOSE      8081-8082 5000 1098 7777 9997

# Start Mule runtime
WORKDIR     /opt/mule
CMD         ["/opt/mule/bin/mule"]
