#!/bin/bash
sudo rm -rf nginx_gzip_build
cd nginx-gzip_offload
./configure --add-module=$(pwd)/../ngx_http_catch_body_filter_module --prefix=$(pwd)/../nginx_gzip_build 
make -j 30
make -j 30 install 
cd ../
sudo cp nginx.conf nginx_gzip_build/conf
ps aux | grep nginx | awk '{print $2}' | xargs sudo kill -s 2
sudo ./nginx_gzip_build/sbin/nginx
f_sz=( "4K" "16K" "32K" )
for i in "${f_sz[@]}"; do
	head -c ${i} < /dev/urandom | sudo tee nginx_gzip_build/html/rand_file_${i}.txt >/dev/null
done
