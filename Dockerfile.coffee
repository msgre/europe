FROM node:latest
RUN npm install -g coffee-script@1.10.0

ENTRYPOINT ["coffee"]
