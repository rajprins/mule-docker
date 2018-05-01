#!/bin/bash


#----- Intro
echo
tput rev
echo "┌──────────────────────────────────────────────────────────────────────────┐"
echo "│ (\_/)     M U L E    D O C K E R    I M A G E    B U I L D E R           │"
echo "│ /   \                                                                    |"
echo "└──────────────────────────────────────────────────────────────────────────┘"
tput sgr0


#----- Set image name
if [[ -z $1 ]] ; then
   NAME="mule4-trial"
else
   NAME=$1
fi


#----- Set runtime version
if [[ -z $2 ]] ; then
   RUNTIME_VERSION=4.1.1
else
   RUNTIME_VERSION=$2
fi


#----- Set environment variable(s)
MULE_BASE="$HOME/mule/${NAME}"


#----- Build Docker image
echo
echo "Building Docker image with label '${NAME}'"
docker build --build-arg RUNTIME_VERSION=${RUNTIME_VERSION} --tag ${NAME} .


#----- No sense in continuing after build failure
if [[ $? -eq 1 ]]
then
   echo
   echo "Error building Docker image. Sorry..."
   echo
   exit 1
fi


#----- Happy scenario
echo
echo "Done. You may now run the Docker image using this command:"
echo "$ docker run -name <CONTAINER_NAME> ${NAME}"
echo
echo "Example of starting the container using HTTP port 8081 mapping and locally mounted data volume:"
echo "$ docker run -t -i --name ${NAME} -p 8081:8081 -v $MULE_BASE/apps:/opt/mule/apps -v $MULE_BASE/logs:/opt/mule/logs ${NAME}"
echo
