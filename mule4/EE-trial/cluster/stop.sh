#!/bin/bash

clear

echo
tput rev
echo "┌─────────────────────────────────────────────────────────────────────────┐"
echo "│ (\_/)      M U L E    D O C K E R    C L U S T E R    R U N N E R       │"
echo "│ /   \                                                                   |"
echo "└─────────────────────────────────────────────────────────────────────────┘"
tput sgr0

echo
docker compose down
