#!/bin/bash
if [ -z "$AGWA_HOST" ]; then
  echo "The AGWA_HOST and AGWA_PORT environments need to be set in your jettyctl config file."
  exit 1
fi

sed -i "s@^agwa.host: .*@agwa.host: $AGWA_HOST@" WEB-INF/agwa.properties
sed -i "s@^agwa.port: .*@agwa.port: $AGWA_PORT@" WEB-INF/agwa.properties
sed -i "s@wayback.urlprefix=.*@wayback.urlprefix=http://$(hostname -f):$PORT/wayback@" WEB-INF/wayback.xml
sed -i "s@8080@$PORT@g" WEB-INF/wayback.xml
sed -i "s@/data/gov2011-12/path-index.txt@$AGWA_PATH_INDEX@g" WEB-INF/wayback.xml
mkdir $1/ROOT
cp -a ./ $1/ROOT/
