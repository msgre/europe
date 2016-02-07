Demo of Europe application.

Right now it consist of two main components:

* Django API backend
* Frontend Javascript application build in Marionette framework

Both components are dockerized and run behind Nginx proxy.

**Content**:

* [Basics](#basics)
    * [Build](#build)
    * [Run](#run)
    * [Watch](#watch)
* [Details](#details)
    * [Database migrations](#database-migrations)
    * [Coffeescript compilation](#coffeescript-compilation)

# Basics

## Build

    docker build -f Dockerfile.api -t msgre/common:europe-api.latest .
    docker build -f Dockerfile.js -t msgre/common:europe-js.latest .
    docker build -f Dockerfile.coffee -t msgre/common:coffee.latest .

## Run

    # API backend based on Django application
    docker run --name europe-api --rm -ti -p 8080:8080 -v $PWD/europe:/src/api msgre/common:europe-api.latest

    # Static files mapped from local directory into container
    docker run --name europe-js --rm -ti -v $PWD/static:/src/js msgre/common:europe-js.latest tail -f /dev/null

    # Nginx in front of Django app and static files
    docker run -ti --rm -p 8081:80 --name nginx --volumes-from europe-js --link europe-api -v $PWD/ansible/files/europe.nginx.conf:/etc/nginx/conf.d/default.conf:ro nginx


NOTE: In production, I will use ready made Javascript container in similar way:

    docker create --name europe-js -v $PWD/static:/src/js msgre/common:europe-js.latest # in production


## Watch

Open in **Chrome** browser URL http://192.168.99.100:8081/europe_01.html
(warning, doesn't work in Firefox due to some problem with keyboard plugin).

For controling web app use following keys (they will be replaced in final 
product to real physical keys):

* `Q` is left
* `W` is right
* `P` is choice

During questions phase, use:

* `0` as wrong answer
* `1` as right answer


# Details

## Database migrations

Run container:

    docker run --name europe-api --rm -ti -p 8080:8080 -v $PWD/europe:/src/api --entrypoint bash msgre/common:europe-api.latest

Or connect to already running europe-api container:

    docker exec -ti europe-api bash

Make and apply migrations:

    ./manage.py makemigrations
    ./manage.py migrate

## Coffeescript compilation

One-time compilation:

    docker run -ti --rm -v $PWD/static/app:/src msgre/common:coffee.latest -bc /src

Continuous compilation based on changes in watched directory:

    fswatch --exclude="\.js$" -o $PWD/static/app | xargs -n1 -I{} docker run -i --rm -v $PWD/static/app:/src msgre/common:coffee.latest -bc /src
