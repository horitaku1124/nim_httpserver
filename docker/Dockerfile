FROM ubuntu:17.10

RUN apt update -y
RUN apt install nim gcc g++ -y
RUN nimble install yaml -y

COPY nim_httpserver.nim /root
COPY http_tools.nim /root
COPY config.yml /root

WORKDIR /root

RUN mkdir /root/public_html
COPY ./public_html/index.html /root/public_html

RUN nim c nim_httpserver.nim
