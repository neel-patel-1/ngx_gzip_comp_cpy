#!/bin/bash
f_sz=( "4K" "16K" "32K" )
for i in "${f_sz[@]}"; do
	head -c ${i} < /dev/urandom | sudo tee nginx_gzip_build/html/rand_file_${i}.txt >/dev/null
	gzip -k -f -1  nginx_gzip_build/html/rand_file_${i}.txt
	size_1=$( stat nginx_gzip_build/html/rand_file_${i}.txt.gz | grep -Eo 'Size: [0-9]+' | grep -Eo '[0-9]+' )
	head -c ${size_1} < /dev/urandom | sudo tee nginx_default_build/html/rand_file_${i}_1.txt >/dev/null

	gzip -k -f -9  nginx_gzip_build/html/rand_file_${i}.txt
	size_9=$( stat nginx_gzip_build/html/rand_file_${i}.txt.gz | grep -Eo 'Size: [0-9]+' | grep -Eo '[0-9]+' )
	head -c ${size_9} < /dev/urandom | sudo tee nginx_default_build/html/rand_file_${i}_9.txt >/dev/null
done

for i in "${f_sz[@]}"; do
	head -c ${i} < /dev/zero | sudo tee nginx_gzip_build/html/zero_file_${i}.txt >/dev/null
	gzip -k -f -1  nginx_gzip_build/html/zero_file_${i}.txt
	size_1=$( stat nginx_gzip_build/html/zero_file_${i}.txt.gz | grep -Eo 'Size: [0-9]+' | grep -Eo '[0-9]+' )
	head -c ${size_1} < /dev/zero | sudo tee nginx_default_build/html/zero_file_${i}_1.txt >/dev/null

	gzip -k -f -9  nginx_gzip_build/html/zero_file_${i}.txt
	size_9=$( stat nginx_gzip_build/html/zero_file_${i}.txt.gz | grep -Eo 'Size: [0-9]+' | grep -Eo '[0-9]+' )
	head -c ${size_9} < /dev/zero | sudo tee nginx_default_build/html/zero_file_${i}_9.txt >/dev/null
done
