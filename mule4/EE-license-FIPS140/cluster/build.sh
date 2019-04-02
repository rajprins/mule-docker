#!/bin/bash


echo
tput rev
echo "┌──────────────────────────────────────────────────────────────────────────┐"
echo "│ (\_/)     M U L E    D O C K E R    I M A G E    B U I L D E R           │"
echo "│ /   \                                                                    |"
echo "└──────────────────────────────────────────────────────────────────────────┘"
tput sgr0

docker-compose build

echo
echo "Done. You may now run the Docker image using this command:"
echo "$ docker-compose up"
echo

