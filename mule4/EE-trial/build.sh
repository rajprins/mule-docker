#!/bin/bash


#----- Intro
clear
echo
tput rev
echo "┌──────────────────────────────────────────────────────────────────────────┐"
echo "│ (\_/)     M U L E    D O C K E R    I M A G E    B U I L D E R           │"
echo "│ /   \                                                                    |"
echo "└──────────────────────────────────────────────────────────────────────────┘"
tput sgr0


NAME="mule4-trial"
RUNTIME_VERSION="4.4.0"

#----- Process command line argument
while getopts ":n:v:" opt; do
  case ${opt} in
    n)
      NAME="${OPTARG}"
      echo "> Setting container name to $OPTARG"
      ;;
    v)
      RUNTIME_VERSION="${OPTARG}"
      echo "> Using Mule version $OPTARG"
      ;;
  esac
done


#----- Set environment variable(s)
MULE_BASE="$HOME/mule/${NAME}"


#----- Build Docker image
echo
echo "Building Mule docker image with label '${NAME}' and runtime version ${RUNTIME_VERSION}"
docker build --build-arg RUNTIME_VERSION=${RUNTIME_VERSION} --tag ${NAME} .


#----- No sense in continuing after build failure
if [[ $? -eq 1 ]] ; then
   echo
   echo "Error building Docker image. Sorry..."
   echo
   exit 1
fi


#----- Happy scenario
echo
echo "Done. You may now run the Docker image using this command:"
echo "$ docker run -name ${NAME}"
echo
echo "Example of starting the container using HTTP port 8081 mapping and locally mounted data volume:"
echo "$ docker run -ti --name ${NAME} -p 8081:8081 -v $MULE_BASE/apps:/opt/mule/apps -v $MULE_BASE/logs:/opt/mule/logs ${NAME}"
echo
