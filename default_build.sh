#!/bin/bash
NGINX_VERSION=1.23.1

if [ ! -d "nginx-${NGINX_VERSION}.tar.gz" ]; then
	wget --no-check-certificate http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
	tar xzf nginx-${NGINX_VERSION}.tar.gz
fi

mkdir -p nginx_default_src && tar -xf nginx-1.23.1.tar.gz -C nginx_default_src --strip-components 1

cd nginx_default_src
./configure --prefix=$(pwd)/../nginx_default_build
make -j 30
make -j 30 install 

cd ../
sudo cp nginx_default.conf nginx_default_build/conf/nginx.conf
ps aux | grep nginx | awk '{print $2}' | xargs sudo kill -s 2
sudo ./nginx_default_build/sbin/nginx

if [ -d "nginx_gzip_build" ]; then
	./file_gen.sh
fi
