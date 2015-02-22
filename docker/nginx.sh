#!/bin/bash

docker run --rm -t --name nginx -p 80:80 -v `pwd`/../static:/usr/share/nginx/html:ro -v `pwd`/nginx:/etc/nginx/conf.d:ro --link europe:europe nginx
docker kill nginx
docker rm nginx
