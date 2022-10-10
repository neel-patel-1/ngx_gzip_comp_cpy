#!/bin/bash
ps aux | grep nginx | awk '{print $2}' | xargs sudo kill -s 2
sudo cp nginx_default.conf nginx_default_build/conf
sudo ./nginx_default_build/sbin/nginx
