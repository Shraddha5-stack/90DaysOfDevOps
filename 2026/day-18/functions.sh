#!/bin/bash

greet() {
    echo "Hello, $1!"
}

add() {
    sum=$(( $1 + $2 ))
    echo "Sum = $sum"
}

greet "Shraddha"

add 10 20
