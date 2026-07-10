#!/bin/bash

read -p "Enter filename: " FILE

if [ -f "$FILE" ]
then
    echo "File Exists"

else
    echo "File Not Found"
fi

