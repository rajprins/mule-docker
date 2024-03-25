#!/bin/bash

echo
tput rev
echo "┌──────────────────────────────────────────────────────────────────────────┐"
echo "│ (\_/)      M U L E    D O C K E R    I M A G E    R U N N E R            │"
echo "│ /o o\                                                                    |"
echo "└──────────────────────────────────────────────────────────────────────────┘"
tput sgr0

echo
echo -n "Enter a name for the container (default: mule4-ee): "
read NAME
if [[ -z $NAME ]] ; then
   NAME="mule4-ee"
fi
echo "Container name: $NAME"

echo
echo -n "Enter a port number for the default HTTP connector port (default: 8081): "
read PORT
if [[ -z $PORT ]] ; then
   PORT="8081"
fi
echo "Port: $PORT"

echo
echo -n "Do you wish to run with (T)erminal output enabled or in (D)etached mode? (Default: T): "
read MODE
if [[ -z $MODE ]] ; then
   MODE="t"
fi

MULE_HOME="/opt/mule"
MULE_BASE="$HOME/mule/$NAME"

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
