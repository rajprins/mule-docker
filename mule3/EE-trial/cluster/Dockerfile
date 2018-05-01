FROM        mule3-trial

MAINTAINER  rajprins@gmail.com

ARG         cluster_conf
ENV         NODE_ID 1
ENV         MULE_ENV dev

COPY        ./resources/$cluster_conf ${MULE_HOME}/.mule/mule-cluster.properties

RUN         sed -i '/wrapper.java.additional.15=-Dorg.quartz.scheduler.skipUpdateCheck=true/a wrapper.java.additional.16=-Dmule.nodeId=%NODE_ID%\nwrapper.java.additional.17=-Dmule.env=%MULE_ENV%' ${MULE_HOME}/conf/wrapper.conf

# Hazelcast ports
EXPOSE      5701 54327
