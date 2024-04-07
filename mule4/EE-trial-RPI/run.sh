#!/bin/bash


#----- Nice, but useless banner
clear
echo
tput rev
echo "┌──────────────────────────────────────────────────────────────────────────┐"
echo "│ (\_/)      M U L E    D O C K E R    I M A G E    R U N N E R            │"
echo "│ /o o\                                                                    |"
echo "└──────────────────────────────────────────────────────────────────────────┘"
tput sgr0
echo


#----- Ask for container instance name
echo -n "> Enter a name for the container (default: mule4-trial-rpi): "
read NAME
if [[ -z ${NAME} ]] ; then
   NAME="mule4-trial-rpi"
fi


#----- HTTP connector's default port is 8081. To which local port should we map this?
echo -n "> Enter a port number for the default HTTP connector port (default: 8081): "
read PORT
if [[ -z $PORT ]] ; then
   PORT="8081"
fi


#----- Ask for output mode
echo -n "> Run container with (T)erminal output enabled or in (D)etached mode? (Default: T): "
read MODE
if [[ -z $MODE ]] ; then
   MODE="t"
elif [ $MODE = "D" ] || [ $MODE = "d" ] || [ $MODE = "T" ] || [ $MODE = "t" ] ; then
   echo
else
   echo
   echo "[ERROR] Wrong input: $MODE. Expected 'T' or 'D'. Aborting."
   echo
   exit 1
fi


#----- Location for mounting volume(s)
MULE_DIR="${HOME}/mule/${NAME}"
if [[ -d ${MULE_DIR} ]] ; then
   sudo rm -rf ${MULE_DIR}
fi


#----- Let's do it...
if [ $MODE = "T" ] || [ $MODE = "t" ] ; then
   echo
   echo "Starting container ${NAME} with terminal output enabled. Data volumes mounted on ${MULE_DIR}."
   docker run -ti --name ${NAME} \
      -p ${PORT}:8081 \
      -v ${MULE_DIR}/logs:/opt/mule/logs \
      -v ${mule_DIR}/apps:/opt/mule/apps \
      -v ${mule_DIR}/domains:/opt/mule/domains \
      -v ${mule_DIR}/conf:/opt/mule/conf \
      ${NAME}
elif [ $MODE = "D" ] || [ $MODE = "d" ] ; then
   echo
   echo "Starting container ${NAME} in detached mode. Data volumes mounted on ${MULE_DIR}."
   docker run -ti --name ${NAME} \
      -p ${PORT}:8081 \
      -v ${MULE_DIR}/logs:/opt/mule/logs \
      -v ${mule_DIR}/apps:/opt/mule/apps \
      -v ${mule_DIR}/domains:/opt/mule/domains \
      -v ${mule_DIR}/conf:/opt/mule/conf \
      ${NAME}
fi