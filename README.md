Demo of Europe application.

Right now it consist of two main components:

* Django API backend
* Frontend Javascript application build in Marionette framework

Both components are dockerized and run behind Nginx proxy.

# Build

    docker build -f Dockerfile.api -t msgre/common:europe-api.latest .
    docker build -f Dockerfile.js -t msgre/common:europe-js.latest .

# Run

    docker run --name europe-api --rm -ti -p 8080:8080 -v $PWD/europe:/src/api msgre/common:europe-api.latest
    docker run --name europe-js --rm -ti -v $PWD/static:/src/js msgre/common:europe-js.latest tail -f /dev/null
    docker create --name europe-js msgre/common:europe-js.latest
    docker run -ti --rm -p 8081:80 --name nginx --volumes-from europe-js --link europe-api -v $PWD/europe.nginx.conf:/etc/nginx/conf.d/default.conf:ro nginx

# Watch

Open in **Chrome** browser URL http://192.168.99.100:8081/europe_01.html
(warning, doesn't work in Firefox due to some problem with keyboard plugin).

For controling web app use following keys (they will be replaced in final 
product to real physical keys):

* `Q` is up
* `A` is down
* `space` is choice

During questions phase, use:

* `0` as wrong answer
* `1` as right answer


# Database migrations

## Run container

    docker run --name europe-api --rm -ti -p 8080:8080 -v $PWD/europe:/src/api --entrypoint bash msgre/common:europe-api.latest

## Make and apply migrations

    ./manage.py makemigrations
    ./manage.py migrate
