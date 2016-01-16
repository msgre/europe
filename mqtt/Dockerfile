FROM java:7

EXPOSE 1883 8000

CMD ["/opt/mqtt_server/bin/run.sh"]

ENV HIVEMQ_VERSION 2.3.1

COPY hivemq-2.3.1.zip /tmp/

RUN cd /tmp \
    && unzip hivemq-${HIVEMQ_VERSION}.zip -d /opt/ \
    && rm hivemq-${HIVEMQ_VERSION}.zip \
    && ln -s /opt/hivemq-${HIVEMQ_VERSION} /opt/mqtt_server

COPY configuration.properties /opt/mqtt_server/conf/
