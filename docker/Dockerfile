FROM ubuntu:17.10

RUN apt-get update -y
RUN apt update -y
RUN apt install nim gcc g++ -y
RUN nimble install yaml -y

COPY nim_httpserver.nim /root
COPY http_tools.nim /root
COPY file_service.nim /root
COPY config.yml /root

WORKDIR /root

RUN mkdir /root/public_html
COPY ./public_html/index.html /root/public_html

RUN nim --threads:on c nim_httpserver.nim
RUN nim --threads:on c nim_http2server.nim
