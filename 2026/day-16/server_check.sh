#!/bin/bash

SERVICE="ssh"

read -p "Do you want to check the status? (y/n): " CHOICE

if [ "$CHOICE" = "y" ]
then
    systemctl is-active $SERVICE

elif [ "$CHOICE" = "n" ]
then
    echo "Skipped."

else
    echo "Invalid Choice"
fi
