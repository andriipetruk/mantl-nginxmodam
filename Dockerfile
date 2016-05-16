FROM nginx

MAINTAINER Andrii Petruk <andrey.petruk@gmail.com>


ENV OPENAM_URL=http://openam:8080/openam AGENT_PROFILE_NAME=WebAgent AGENT_PASSWORD=password CONFIRM=y


RUN apt-get update && \
        apt-get install -y wget unzip libnspr4 libnss3 libxml2 libpcre3 libssl1.0.0 libssl-dev && \
        rm -rf /var/lib/apt/lists/*

RUN wget -P /tmp -q --no-check-certificate \
        https://www.osstech.co.jp/download/hamano/nginx/nginx_agent_20141119.deb.x86_64.zip && \
        unzip /tmp/nginx_agent_20141119.deb.x86_64.zip -d /opt && \
        rm /tmp/nginx_agent_20141119.deb.x86_64.zip



RUN rm /opt/nginx_agent/conf/nginx.conf && \
    ln -s  /root/conf/nginx.conf /opt/nginx_agent/conf/nginx.conf

WORKDIR /opt/nginx_agent/

CMD ./bin/agentadmin.sh && ./bin/nginx -c ./conf/nginx.conf -g "daemon off;"
