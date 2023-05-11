FROM alpine:latest

RUN apk update && apk add postgresql-client

COPY code/ /code/

EXPOSE 3000:3000

WORKDIR /code

ENTRYPOINT /code/deploy.sh