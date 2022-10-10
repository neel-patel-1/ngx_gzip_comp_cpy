#!/bin/bash
f_sz=( "4K" "16K" "32K" )
for i in "${f_sz[@]}"; do
	head -c ${i} < /dev/urandom | sudo tee nginx_gzip_build/html/rand_file_${i}.txt >/dev/null
	gzip -k -f -1  nginx_gzip_build/html/rand_file_${i}.txt
	size=$( stat nginx_gzip_build/html/rand_file_${i}.txt.gz | grep -Eo 'Size: [0-9]+' | grep -Eo '[0-9]+' )
	head -c ${size} < /dev/urandom | sudo tee nginx_default_build/html/rand_file_${i}.txt >/dev/null
done

for i in "${f_sz[@]}"; do
	head -c ${i} < /dev/zero | sudo tee nginx_gzip_build/html/zero_file_${i}.txt >/dev/null
	gzip -k -f -1  nginx_gzip_build/html/zero_file_${i}.txt
	size=$( stat nginx_gzip_build/html/zero_file_${i}.txt.gz | grep -Eo 'Size: [0-9]+' | grep -Eo '[0-9]+' )
	head -c ${size} < /dev/zero | sudo tee nginx_default_build/html/zero_file_${i}.txt >/dev/null
done
