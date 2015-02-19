#!/bin/bash

docker run --name europe -t -v `pwd`/../europe:/usr/src/app -p 0.0.0.0:8000:8000 msgre/europe runserver 0.0.0.0:8000
docker kill europe
docker rm europe
