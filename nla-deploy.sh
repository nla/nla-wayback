#!/bin/bash
if [ -z "$AGWA_URL" ]; then
  echo "The AGWA_URL environment varable needs to be set in your jettyctl config file."
  exit 1
fi

# WAYBACK_URL *must* be specified as a relative URI, e.g. '/gov/wayback/'

sed -i "s@^agwa.url: .*@agwa.url: $AGWA_URL@" src/main/webapp/WEB-INF/agwa.properties
sed -i "s@^wayback.url: .*@wayback.url: ${WAYBACK_URL%/}@" src/main/webapp/WEB-INF/agwa.properties
sed -i "s@wayback.urlprefix=.*@wayback.urlprefix=${WAYBACK_URL%/}/@" src/main/webapp/WEB-INF/wayback.xml

sed -i "s@8080@$PORT@g" src/main/webapp/WEB-INF/wayback.xml
sed -i "s@/data/agwa/indexes/agwa-path-index.txt@$AGWA_PATH_INDEX@g" src/main/webapp/WEB-INF/wayback.xml src/main/webapp/WEB-INF/CDXCollection.xml
mkdir $1/ROOT
cp -a ./ $1/ROOT/
