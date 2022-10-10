#!/bin/bash
NGINX_VERSION=1.23.1
if [ ! -d "nginx-${NGINX_VERSION}" ]; then
	wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
	tar xzf nginx-${NGINX_VERSION}.tar.gz
fi
