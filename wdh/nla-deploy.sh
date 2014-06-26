#!/bin/bash
mvn package
unzip -d $1/ROOT target/*.war
