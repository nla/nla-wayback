#!/bin/bash
sed -i "s@8080@$PORT@g" src/main/webapp/WEB-INF/wayback.xml
mvn package
unzip -d $1/ROOT target/*.war
