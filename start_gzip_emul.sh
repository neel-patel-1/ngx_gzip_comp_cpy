#!/bin/bash
ps aux | grep nginx | awk '{print $2}' | xargs sudo kill -s 2
sudo cp nginx.conf nginx_gzip_build/conf
sudo ./nginx_gzip_build/sbin/nginx
