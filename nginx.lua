worker_processes	1;

events {
    worker_connections	1024;
}

  error_log /opt/nginx_agent/logs/error.log  debug;

{{$SSL := or (key "config/mantlui/ssl") (or (env "MANTLUI_SSL") "false") | parseBool}}
{{$AUTH := or (key "config/mantl/auth") (or (env "MANTLUI_AUTH") "false") | parseBool}}
{{$consulSSL := or (key "config/mantl/consul_ssl") (or (env "CONSUL_SSL") "false") | parseBool}}

http {
    include		mime.types;
    default_type	application/octet-stream;

    sendfile		on;
    keepalive_timeout	65;

    send_timeout 20;
    proxy_buffering on;
    proxy_buffer_size 8k;
    proxy_buffers 2048 8k;

  error_log /opt/nginx_agent/logs/error.log  debug_http;
  access_log /opt/nginx_agent/logs/access.log;


    am_boot_file "/opt/nginx_agent/conf/OpenSSOAgentBootstrap.properties";
    am_conf_file "/opt/nginx_agent/conf/OpenSSOAgentConfiguration.properties";

    {{$mesos := service "leader.mesos" "any"}}{{with $mesos}}
    upstream mesos { {{range $mesos}}
        server {{.Address}}:{{.Port}};{{end}}
    } {{end}}

    {{$marathon := service "marathon" "any"}}{{with $marathon}}
    upstream marathon { {{range $marathon}}
        server {{.Address}}:{{.Port}};{{end}}
    } {{end}}

    {{$kubernetes_ui := service "nodeport" "any"}}{{with $kubernetes_ui}}
    upstream kubernetes_ui { {{range $kubernetes_ui}}
        server {{.Address}}:30000;{{end}}
    } {{end}}

    {{$chronos := service "chronos" "any"}}{{with $chronos}}
    upstream chronos { {{range $chronos}}
        server {{.Address}}:{{.Port}};{{end}}
    } {{end}}

    {{$consul := service "consul" "any"}}{{with $consul}}
    upstream consul { {{range $consul}}
        server {{.Address}}:8500;{{end}}
    } {{end}}

    {{$mantlapi := service "mantl-api" "any"}}{{with $mantlapi}}
    upstream mantlapi { {{range $mantlapi}}
        server {{.Address}}:{{.Port}};{{end}}
    } {{end}}

    {{$traefikAdmin := service "traefik-admin" "any"}}{{with $traefikAdmin}}
    upstream traefik-admin { {{range $traefikAdmin}}
        server {{.Address}}:{{.Port}};{{end}}
    } {{end}}

    {{$kibana := (or (service "kibana-mantl-task" "any") (service "kibana-mantl" "any") (service "kibana" "any"))}}{{with $kibana}}
    upstream kibana { {{range $kibana}}
        server {{.Address}}:{{.Port}};{{end}}
    } {{end}}

    {{$elasticsearch := (or (service "elasticsearch-mantl" "any") (service "elasticsearch" "any"))}}{{with $elasticsearch}}
    upstream elasticsearch { {{range $elasticsearch}}
        server {{.Address}}:{{.Port}};{{end}}
    } {{end}}

    {{$kafka_api := service "kafka-mantl" "any"}}{{with $kafka_api}}
    upstream kafka-api { {{range $kafka_api}}
        server {{.Address}}:{{.Port}};{{end}}
    } {{end}}

    {{if $SSL}}
    server {
        listen 80;
        return 301 https://$host$request_uri;
    }
    {{end}}

    server {
        listen {{if $SSL}}443 ssl{{else}}80{{end}};
        
        {{if $SSL}}
        ssl_certificate     {{or (env "CERTFILE") "/etc/nginx/ssl/nginx.cert"}};
        ssl_certificate_key	{{or (env "KEYFILE")  "/etc/nginx/ssl/nginx.key"}};

        ssl on;
        ssl_session_cache         builtin:1000 shared:SSL:10m;
        ssl_protocols             TLSv1 TLSv1.1 TLSv1.2;
        ssl_ciphers               {{or (key "config/mantlui/ssl_ciphers") "HIGH:!aNULL:!eNULL:!EXPORT:!CAMELLIA:!DES:!MD5:!PSK:!RC4"}};
        ssl_prefer_server_ciphers on;

        error_page 497 https://$host:$server_port$request_uri;
        {{end}}

       {{if $AUTH}}
        auth_basic              on;
        auth_basic_user_file    /etc/nginx/nginx-auth.conf;
        {{end}}


        error_log /opt/nginx_agent/logs/error.log  debug;
        access_log /opt/nginx_agent/logs/access.log;
        
       
        location / {
            proxy_connect_timeout	600;
            proxy_send_timeout	600;
            proxy_read_timeout	600;
            send_timeout		600;

            root /usr/share/nginx/html;
            index index.html index.htm;
            try_files $uri $uri/ =404;
        }

        {{with $mesos}}
        location = /mesos {
            return 301 /mesos/;
        }

        location = /mesos/ {
            root /usr/share/nginx/html;
        }

        location /mesos {
            try_files $uri @mesos-upstream;
            root /usr/share/nginx/html;
        }

        location @mesos-upstream {
            proxy_set_header host              $host;
            proxy_set_header x-real-ip         $remote_addr;
            proxy_set_header x-forwarded-for   $proxy_add_x_forwarded_for;
            proxy_set_header x-forwarded-proto $scheme;

            rewrite    /mesos/(.+)$ /$1 break;
            proxy_pass http://mesos;
        } {{end}}

        {{range service "agent.mesos" "any"}}
        location ~ /mesos/slave/{{index (.ID | split ":") 2}}/(.*) {
            proxy_set_header        Host $host;
            proxy_set_header        X-Real-IP $remote_addr;
            proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header        X-Forwarded-Proto $scheme;
            proxy_pass http://{{.Address}}:{{.Port}}/$1$is_args$args;
        }{{end}}

         location /lua {
            root   html;
            index  index.html index.htm;
            content_by_lua_file marathon.lua;
        }

        {{with $marathon}}
        location /marathon/ {
            proxy_set_header        host $host;
            proxy_set_header        x-real-ip $remote_addr;
            proxy_set_header        x-forwarded-for $proxy_add_x_forwarded_for;
            proxy_set_header        x-forwarded-proto $scheme;
            proxy_pass http://marathon/;
        } {{end}}

        {{with $kubernetes_ui}}
        location /kubernetes/ {
            proxy_set_header        host $host;
            proxy_set_header        x-real-ip $remote_addr;
            proxy_set_header        x-forwarded-for $proxy_add_x_forwarded_for;
            proxy_set_header        x-forwarded-proto $scheme;
            proxy_pass http://kubernetes_ui/;
        } {{end}}

        {{with $chronos}}
        location /chronos/ {
            proxy_set_header        host $host;
            proxy_set_header        x-real-ip $remote_addr;
            proxy_set_header        x-forwarded-for $proxy_add_x_forwarded_for;
            proxy_set_header        x-forwarded-proto $scheme;
            proxy_pass http://chronos/;
        } {{end}}

        {{with $consul}}
        location ~ /consul/(v1\/.*) {
            proxy_set_header        host $host;
            proxy_set_header        x-real-ip $remote_addr;
            proxy_set_header        x-forwarded-for $proxy_add_x_forwarded_for;
            proxy_set_header        x-forwarded-proto $scheme;
            proxy_set_header        Authorization "Basic YWRtaW46cmVkaGF0Cg==";
            proxy_pass {{if $consulSSL}}https{{else}}http{{end}}://consul/$1$is_args$args;
        } {{end}}

        location /consul {
            root /usr/share/nginx/html;
            index index.html index.htm;
            try_files $uri $uri/ =404;
        }

        {{with $mantlapi}}
        location /api/ {
            proxy_set_header        host $host;
            proxy_set_header        x-real-ip $remote_addr;
            proxy_set_header        x-forwarded-for $proxy_add_x_forwarded_for;
            proxy_set_header        x-forwarded-proto $scheme;
            proxy_pass http://mantlapi/;
        } {{end}}

        {{with $traefikAdmin}}
        location = /traefik {
            return 301 /traefik/dashboard/;
        }

        location /traefik {
            try_files $uri $uri/ @traefik-upstream;
            index index.html;
            root /usr/share/nginx/html;
        }

        location @traefik-upstream {
            proxy_set_header host              $host;
            proxy_set_header x-real-ip         $remote_addr;
            proxy_set_header x-forwarded-for   $proxy_add_x_forwarded_for;
            proxy_set_header x-forwarded-proto $scheme;

            rewrite    /traefik/(.+)$ /$1 break;
            proxy_pass https://traefik-admin;
        }
        {{end}}

        {{with $elasticsearch}}
        location /elasticsearch/ {
            proxy_set_header        host $host;
            proxy_set_header        x-real-ip $remote_addr;
            proxy_set_header        x-forwarded-for $proxy_add_x_forwarded_for;
            proxy_set_header        x-forwarded-proto $scheme;
            proxy_pass http://elasticsearch/;
        } {{end}}

        {{with $kibana}}
        location /kibana {
            proxy_set_header host              $host;
            proxy_set_header x-real-ip         $remote_addr;
            proxy_set_header x-forwarded-for   $proxy_add_x_forwarded_for;
            proxy_set_header x-forwarded-proto $scheme;
            rewrite    /kibana/(.+)$ /$1 break;
            proxy_pass http://kibana/;
        } {{end}}

        {{with $kafka_api}}
        location /kafka/ {
            proxy_set_header        host $host;
            proxy_set_header        x-real-ip $remote_addr;
            proxy_set_header        x-forwarded-for $proxy_add_x_forwarded_for;
            proxy_set_header        x-forwarded-proto $scheme;
            proxy_pass http://kafka-api/;
        } {{end}}
       
    }
}