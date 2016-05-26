FROM nginx

MAINTAINER Andrii Petruk <andrey.petruk@gmail.com>


ENV CONSUL_TEMPLATE_VERSION=0.12.2 OPENAM_URL=http://openam:8080/openam AGENT_PROFILE_NAME=WebAgent AGENT_PASSWORD=password CONFIRM=y


RUN apt-get update && \
        apt-get install -y wget unzip libnspr4 libnss3 libxml2 libpcre3 libssl1.0.0 libssl-dev && \
        rm -rf /var/lib/apt/lists/*


ADD https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip /

RUN unzip consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip && \
    mv consul-template /usr/local/bin/consul-template &&\
    rm -rf /consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip && \
    mkdir -p /consul-template
#    mkdir -p /consul-template /consul-template/config.d /consul-template/templates


RUN mkdir -p /etc/nginx /tmp/nginx /defaults /etc/nginx/templates

ADD defaults/ /defaults
ADD scripts /scripts/

ADD http://www.osstech.co.jp/download/hamano/nginx/nginx_agent_20141119.deb.x86_64.zip /tmp

RUN unzip /tmp/nginx_agent_20141119.deb.x86_64.zip -d /opt && \
    rm /tmp/nginx_agent_20141119.deb.x86_64.zip && \
    rm /opt/nginx_agent/conf/nginx.conf


RUN mkdir -p /usr/share/nginx
COPY html /usr/share/nginx/html


#COPY nginx.tmpl /consul-template/templates/
#COPY services.json.tmpl /consul-template/templates/
#COPY consul.cfg /consul-template/config.d/


CMD ["/scripts/launch.sh"]
#CMD [ "/usr/local/bin/consul-template"]
