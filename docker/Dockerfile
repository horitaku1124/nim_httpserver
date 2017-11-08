FROM ubuntu:17.10

RUN apt update -y
RUN apt install nim -y
RUN nimble install yaml -y

COPY nim_httpserver.nim /root
COPY http.nim /root
COPY config.yml /root

WORKDIR /root

RUN nim c nim_httpserver.nim

RUN mkdir /root/public_html
COPY ./public_html/index.html /root/public_html