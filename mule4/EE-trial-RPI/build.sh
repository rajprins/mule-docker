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
   NAME="mule4-trial-rpi"
else
   NAME=$1
fi


#----- Set runtime version
if [[ -z $2 ]] ; then
   RUNTIME_VERSION=4.2.0
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
