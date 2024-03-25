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
echo


read -p "What name do you want to use for this container image (RETURN=mule4-ee) : " NAME
if [[ -z $NAME ]] ; then
  NAME="mule4-ee"  
fi

read -p "What runtime version do you want to use (RETURN=4.6.1) : " RUNTIME_VERSION
if [[ -z $RUNTIME_VERSION ]] ; then
  RUNTIME_VERSION="4.6.1"
fi

read -p "Enter your Nexus username for downloading the runtime : " USERNAME
while [[ -z "$USERNAME" ]]
do
  read -p "[ERROR] Nexus username can not be empty, enter your username: " USERNAME
done

read -s -p "Enter your Nexus password : " PASSWORD
while [[ -z "$PASSWORD" ]]
do
  echo
  read -s -p "[ERROR] Nexus password can not be empty, enter your password: " PASSWORD
done



#----- Set environment variable(s)
MULE_BASE="$HOME/mule/${NAME}"


#----- Build Docker image
echo
echo "Building Mule docker image with label '${NAME}' and runtime version ${RUNTIME_VERSION}"
docker build --build-arg RUNTIME_VERSION=${RUNTIME_VERSION} --build-arg USERNAME=$USERNAME --build-arg PASSWORD=$PASSWORD --tag ${NAME} .


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
