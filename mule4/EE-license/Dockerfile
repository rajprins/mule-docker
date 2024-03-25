FROM         azul/zulu-openjdk
MAINTAINER   Roy Prins <rajprins@gmail.com>

# Define environment variables
ARG         RUNTIME_VERSION
ARG         USERNAME
ARG         PASSWORD

ENV         MULE_HOME="/opt/mule"
ENV         DOWNLOAD_URL="https://repository-master.mulesoft.org/nexus/content/repositories/ci-releases/com/mulesoft/mule/distributions/mule-ee-distribution-standalone/${RUNTIME_VERSION}/mule-ee-distribution-standalone-${RUNTIME_VERSION}.zip"

# Install necessary system tools
RUN         apt-get update && \
            apt-get install -y curl wget unzip vim && \
            rm -rf /var/lib/apt/lists/* && \
            apt-get autoclean

# Download and install Mule runtime
WORKDIR     /opt
RUN         curl -u ${USERNAME}:${PASSWORD} ${DOWNLOAD_URL} -o runtime.zip && \
            unzip runtime.zip && \
            rm runtime.zip && \
            ln -s /opt/mule-enterprise-standalone-${RUNTIME_VERSION} ${MULE_HOME}

# Define mount points
VOLUME      ["${MULE_HOME}/logs", "${MULE_HOME}/apps", "${MULE_HOME}/domains", "${MULE_HOME}/conf"]
#VOLUME      ["${MULE_HOME}/logs", "${MULE_HOME}/apps"]

# Copy and install License file
COPY        ./resources/license.lic ${MULE_HOME}/conf/
RUN         ${MULE_HOME}/bin/mule -installLicense ${MULE_HOME}/conf/license.lic

# Expose the necessary port ranges as required by the Mule Apps
# HTTP listener default ports, remote debugger, JMX, MMC agent, AMC agent
EXPOSE      8081-8082 5000 1098 7777 9997

# Start Mule runtime
WORKDIR     ${MULE_HOME}
CMD         ["./bin/mule"]

