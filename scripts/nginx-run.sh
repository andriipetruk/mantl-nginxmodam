#!/bin/bash

set -x

if [ ! -s /opt/nginx_agent/conf/nginx.conf ]; then
  exit 0
fi

/opt/nginx_agent/bin/nginx -s reload
if [ $? -eq 0 ]; then
  /bin/echo "Reloading nginx..."
  exit 0
fi

/bin/echo "Checking nginx.conf..."
cd /opt/nginx_agent
/opt/nginx_agent/bin/nginx -t -c /opt/nginx_agent/conf/nginx.conf
if [ $? -ne 0 ]; then
  /bin/echo "nginx.conf check failed..."
  exit 1
fi

/bin/echo "Starting nginx..."
cd /opt/nginx_agent
/opt/nginx_agent/bin/nginx -c /opt/nginx_agent/conf/nginx.conf -g "daemon off;"
exit $?
