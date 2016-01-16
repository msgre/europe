#!/bin/bash

docker kill nginx
docker rm nginx
docker kill europe-api
docker rm europe-api
docker rm europe-js
