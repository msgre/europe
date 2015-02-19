#!/bin/bash

docker run --rm -ti -v `pwd`/../europe:/usr/src/app msgre/europe shell_plus
