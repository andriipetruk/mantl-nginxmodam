FROM centos:centos6

MAINTAINER Andrii Petruk <andrey.petruk@gmail.com>


ENV CONSUL_TEMPLATE_VERSION=0.10.0
#OPENAM_URL=http://openam:8080/openam AGENT_PROFILE_NAME=WebAgent AGENT_PASSWORD=password CONFIRM=y


RUN yum -y install unzip  zlib-devel nspr-devel nss-devel libxml2-devel pcre-devel openssl-dev && \
    ln -s /lib64/libpcre.so.0 /lib64/libpcre.so.1

ADD https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip /

RUN unzip consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip && \
    mv consul-template /usr/local/bin/consul-template &&\
    rm -rf /consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip && \
    mkdir -p /consul-template /consul-template/config.d /consul-template/templates


RUN mkdir -p /etc/nginx /tmp/nginx /defaults /etc/nginx/templates

ADD defaults/ /defaults
ADD scripts /scripts/

COPY nginx_Linux_64_agent_4.0.0-SNAPSHOT.zip /tmp

RUN unzip /tmp/nginx_Linux_64_agent_4.0.0-SNAPSHOT.zip -d /opt && \
    mv /opt/web_agents/nginx_agent /opt/nginx_agent && rm -rf /opt/web_agents \
    rm /tmp/nginx_Linux_64_agent_4.0.0-SNAPSHOT.zip \
    rm -rf /opt/nginx_agent/html \
    rm /opt/nginx_agent/conf/nginx.conf \


COPY OpenSSOAgentConfiguration.properties /opt/nginx_agent/conf/OpenSSOAgentConfiguration.properties 

RUN mkdir -p /usr/share/nginx
COPY html /usr/share/nginx/html
COPY marathon_wrapper /usr/share/nginx/marathon_wrapper
ADD error /opt/nginx_agent/error
COPY nginx.tmpl /consul-template/templates/
COPY services.json.tmpl /consul-template/templates/
COPY index_html.tmpl /consul-template/templates/
COPY consul.cfg /consul-template/config.d/


CMD ["/scripts/launch.sh"]
#CMD [ "/usr/local/bin/consul-template"]
