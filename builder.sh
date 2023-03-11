#!/bin/bash

for var in "$@"
do
    git clone git@EBSCO:EBSCOIS/"$var".git
    cp mvnw "$var"/
    cp .mvn -R "$var"/
    cd "$var" && ./mvnw clean install
done

