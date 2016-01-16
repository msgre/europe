This is demo based on MQTT communication between physical HW and Javascript
application.

Idea is to have one MQTT server (HiveMQ) on which is connected Arduino device
and Javascript application. Each time ball is crossing one of the gate,
message about this event will be published on `game` topic. Javascript code
subscribed to same topic get notified and make appropriate action.

This code is proof of concept. It have MQTT server hidden inside Docker container,
instead of Arduino device HiveMQ demo client, and simple Javascript application
showing received messages.

# Run

    docker run -p 8000:8000 -p 1883:1883 --rm -ti --name hivemq msgre/common:europe-mqtt

# Build

    docker build -t msgre/common:europe-mqtt .

# Javascript test

1) Run hivemq container (see above)
2) Go into `js/` directory and run: `python -m SimpleHTTPServer`
3) Open in your Chrome browser URL `http://localhost:8000/`
4) Open in second Chrome browser URL `http://www.hivemq.com/demos/websocket-client/`,
   fill **Host** and **Port** fields and click Connect. After successfull 
   connection fill `game` value into **Topic** field, some **message** and click
   **Publish** button. You should see now same message in first Chrome window
   with our demo app.

Note about host/port: Basicaly you must fill IP address and port of your running
HiveMQ server. On OSX it is hidden in docker machine, so first you must find
IP address with `docker-machine ls`. Port should be 8000 (thanks to explicit
mapping in `docker run` command).
