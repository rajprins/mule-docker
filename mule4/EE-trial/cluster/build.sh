#!/bin/bash

clear
echo
tput rev
echo "┌──────────────────────────────────────────────────────────────────────────┐"
echo "│ (\_/)     M U L E    D O C K E R    I M A G E    B U I L D E R           │"
echo "│ /   \                                                                    |"
echo "└──────────────────────────────────────────────────────────────────────────┘"
tput sgr0

docker compose build

#----- No sense in continuing after build failure
if [[ $? -eq 1 ]] ; then
   echo
   echo "Error building Docker image. Sorry..."
   echo
   exit 1
fi


echo
echo "Done. You may now run the Docker image using this command:"
echo "$ docker compose up"
echo

