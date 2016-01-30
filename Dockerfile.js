FROM python:2.7

RUN mkdir -p /src/js

VOLUME ["/src/js"]
WORKDIR "/src/js"
CMD ["/bin/true"]

ADD ./static /src/js
