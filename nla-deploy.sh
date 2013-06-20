#!/bin/bash
if [ -z "$AGWA_URL" ]; then
  echo "The AGWA_URL environment varable needs to be set in your jettyctl config file."
  exit 1
fi

if [ -z "$WAYBACK_HOST" ]; then
  WAYBACK_HOST="$(hostname -f)"
fi

if [ -z "$WAYBACK_URL" ]; then
  WAYBACK_URL=http://${WAYBACK_HOST}:${PORT}${ROOT_URL_PREFIX-}/wayback/
fi

sed -i "s@^agwa.url: .*@agwa.url: $AGWA_URL@" WEB-INF/agwa.properties
sed -i "s@wayback.urlprefix=.*@wayback.urlprefix=${WAYBACK_URL}@" WEB-INF/wayback.xml
sed -i "s@8080@$PORT@g" WEB-INF/wayback.xml
sed -i "s@/data/gov2011-12/path-index.txt@$AGWA_PATH_INDEX@g" WEB-INF/wayback.xml WEB-INF/CDXCollection.xml
mkdir $1/ROOT
cp -a ./ $1/ROOT/
