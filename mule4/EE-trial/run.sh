#!/bin/bash


#----- Nice, but useless banner
clear
echo
tput rev
echo "┌──────────────────────────────────────────────────────────────────────────┐"
echo "│ (\_/)      M U L E    D O C K E R    I M A G E    R U N N E R            │"
echo "│ /   \                                                                    |"
echo "└──────────────────────────────────────────────────────────────────────────┘"
tput sgr0


#----- Ask for container instance name
echo
echo -n "Enter a name for the container (default: mule4-trial): "
read NAME
if [[ -z ${NAME} ]] ; then
   NAME="mule4-trial"
fi


#----- HTTP connector's default port is 8081. To which local port should we map this?
echo
echo -n "Enter a port number for the default HTTP connector port (default: 8081): "
read PORT
if [[ -z $PORT ]] ; then
   PORT="8081"
fi


#----- Ask for output mode
echo
echo -n "Run container with (T)erminal output enabled or in (D)etached mode? (Default: T): "
read MODE
if [[ -z $MODE ]] ; then
   MODE="t"
fi


#----- Environment variables
MULE_HOME="/opt/mule"
MULE_BASE="${HOME}/mule/${NAME}"


#----- Let's do it...
if [ $MODE = "T" ] || [ $MODE = "t" ] ; then
   echo "Starting container ${NAME} with terminal output enabled. Data volumes mounted on ${MULE_BASE}."
   docker run -ti --name ${NAME} \
      -p ${PORT}:8081 \
      -v ${MULE_BASE}/apps:${MULE_HOME}/apps \
      -v ${MULE_BASE}/logs:${MULE_HOME}/logs \
      ${NAME}
elif [ $MODE = "D" ] || [ $MODE = "d" ] ; then
   echo "Starting container ${NAME} in detached mode. Data volumes mounted on ${MULE_BASE}."
   docker run -d --name ${NAME} \
      -p ${PORT}:8081 \
      -v ${MULE_BASE}/apps:${MULE_HOME}/apps \
      -v ${MULE_BASE}/logs:${MULE_HOME}/logs \
      ${NAME}
else
   echo "Wrong input: $MODE. Expected 'T' or 'D'. Aborting..."
   exit 1
fi
