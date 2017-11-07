FROM ubuntu:17.10

RUN apt update -y
RUN apt install nim -y

COPY nim_httpserver.nim /root
COPY http.nim /root
COPY config.yml /root

WORKDIR /root

RUN nimble install yaml -y
RUN nim c nim_httpserver.nim
# CMD ["nim c -r nim_httpserver.nim"]