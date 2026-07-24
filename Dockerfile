# SABOTAGE: Bloated base image running as root by default
FROM node:latest

WORKDIR /usr/src/app

EXPOSE 8080
CMD [ "node" ]

COPY . .