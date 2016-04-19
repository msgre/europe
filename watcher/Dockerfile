FROM python:3.5

WORKDIR "/src"
EXPOSE 8082
ENTRYPOINT ["crossbar"]
CMD ["start"]

RUN pip install pyserial minimalmodbus autobahn[twisted]==0.13.1 crossbar

ADD watcher /src/
