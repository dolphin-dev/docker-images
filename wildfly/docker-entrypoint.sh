#!/bin/bash

set -e

if [ -n "$DS_PORT_5432_TCP_ADDR" ]; then
  DB_HOST="$DS_PORT_5432_TCP_ADDR"
fi

if [ -n "$DS_PORT_5432_TCP_PORT" ]; then
  DB_PORT="$DS_PORT_5432_TCP_PORT"
fi

if [ -z "$DB_HOST" ]; then
  DB_HOST='localhost'
fi

if [ -z "$DB_PORT" ]; then
  DB_PORT='5432'
fi

echo "=> Starting WildFly server... "
echo "=> DB_HOST = " $DB_HOST
echo "=> DB_PORT = " $DB_PORT

# Set execute command
JBOSS_HOME=/opt/jboss/wildfly
JBOSS_MODE=standalone
JBOSS_CONFIG=standalone-dolphin.xml
BIND_ADDRESS=0.0.0.0

# WildFly Bind Address
if [ "$#" -eq 1 ]; then 
  BIND_ADDRESS="$1"
fi

# Execute
$JBOSS_HOME/bin/$JBOSS_MODE.sh \
		 -c $JBOSS_CONFIG \
		 -b $BIND_ADDRESS \
                 -Ddb.host=$DB_HOST \
                 -Ddb.port=$DB_PORT

exit 0
