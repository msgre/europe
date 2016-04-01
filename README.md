Demo of Europe application compounded from several components:

* Django API backend
* Django Admin backend
* Python Watcher script, which read status from HW boards and send events
  through websocket connection to browser
* Frontend Javascript application build in Marionette framework

All components are dockerized and run behind Nginx proxy.

**Content**:

* [Basics](#basics)
    * [Build](#build)
    * [Run](#run)
    * [Watch](#watch)
* [Details](#details)
    * [Database migrations](#database-migrations)
    * [Coffeescript compilation](#coffeescript-compilation)
    * [LESS compilation](#less-compilation)
    * Debug mode for Javascript application

# Basics

## Build

    docker build -f Dockerfile.base -t msgre/common:europe-base.latest .
    docker build -f Dockerfile.coffee -t msgre/common:coffee.latest .
    docker-compose build
    cd watcher/ && docker build -t msgre/common:europe-watcher.latest .

`base` is general Django container, `coffee` is helper container for compiling 
CoffeeScript files into Javascript, `watcher` take care about HW monitoring
and publish events on websockets.

## Run

    docker-compose up

When you hit CTRL+C, containers will be stopped. Sometimes this is not true,
so you must run manually:

    docker-compose kill

If you want remove stopped containers, call:

    docker-compose rm

## Watch

Open in **Chrome** browser URL http://192.168.99.100:8081/
(warning, doesn't work in Firefox due to disfunctional keyboard plugin).

For controling web app use following keys (they will be replaced in final 
product to real physical keys):

* `Q` is left
* `W` is right
* `P` is choice

During questions phase, use:

* `0` as wrong answer
* `1` as right answer

If you run `watcher` container in debug mode, you could simulate HW events by
touching files in `watcher/gates` directory. For example:

    touch watcher/gates/14/1

will simulate ball passing gate number 1 on board 14. Same way you could 
simulate keyboard events.

## Administration

There is standard Django admin interface on http://192.168.99.100:8081/admin.
You could modify there options, questions, and several other details about
game.

# Details

## Database migrations

Connect to already running `api` container:

    docker exec -ti api bash

Make and apply migrations:

    ./manage.py makemigrations --settings europe.settings_api
    ./manage.py migrate --settings europe.settings_api

## Coffeescript compilation

One-time compilation:

    docker run -ti --rm -v $PWD/static/app:/src msgre/common:coffee.latest -bc /src

Continuous compilation based on changes in watched directory:

    fswatch --exclude="\.js$" -o $PWD/static/app | xargs -n1 -I{} docker run -i --rm -v $PWD/static/app:/src msgre/common:coffee.latest -bc /src

## LESS compilation

One-time compilation:

    docker run -i --rm -v $PWD/static/css:/src ewoutp/lessc:latest /src/styles.less > $PWD/static/css/styles.css

## Debug mode for Javascript application

For debugging purposes you could add special URL parameters to directly enter
one of the Javascript application screens. In this case timeouts (part of code
that return you to initial `intro` page) will be set to very high value, so
you stay on given page for very long time (and you could debug HTML/CSS/JS 
things with peace in mind).

Enter URLs like `http://192.168.99.100:8081/?intro`. Last part after `?` 
character tells in which page you are interested. Enter one of this values:
`intro`, `crossroad`, `scores`, `gamemode`, `countdown`, `game`, `result`, 
`recap`, `score`.
