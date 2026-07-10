#!/bin/bash

local_demo() {

    local NAME="Shraddha"

    echo "Inside Function: $NAME"

}

global_demo() {

    ROLE="DevOps Engineer"

}

local_demo

echo "Outside Function: $NAME"

global_demo

echo "Role: $ROLE"
