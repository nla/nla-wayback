#!/bin/bash
if [ -z "$AGWA_URL" ]; then
  echo "The AGWA_URL environment varable needs to be set in your jettyctl config file."
  exit 1
fi

if [[ $WAYBACK_URL =~ ^http://[^/]+(/.*)$ ]]; then
  WAYBACK_PATH="${BASH_REMATCH[1]}"
else
  WAYBACK_PATH="$WAYBACK_URL"
fi

sed -i "s@^agwa.url: .*@agwa.url: $AGWA_URL@" src/main/webapp/WEB-INF/agwa.properties
sed -i "s@^wayback.url: .*@wayback.url: ${WAYBACK_PATH%/}@" src/main/webapp/WEB-INF/agwa.properties
sed -i "s@wayback.urlprefix=.*@wayback.urlprefix=${WAYBACK_URL%/}/@" src/main/webapp/WEB-INF/wayback.xml

sed -i "s@8080@$PORT@g" src/main/webapp/WEB-INF/wayback.xml
sed -i "s@/data/agwa/indexes/agwa-path-index.txt@$AGWA_PATH_INDEX@g" src/main/webapp/WEB-INF/wayback.xml src/main/webapp/WEB-INF/CDXCollection.xml
mvn package
unzip -d $1/ROOT target/*.war
