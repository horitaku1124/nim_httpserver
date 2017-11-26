# Nim http server

## Run

```
nimble install yaml
nim c nim_httpserver2.nim
./nim_httpserver2
```


## Test on docker
```
cd docker
docker build ../ -f Dockerfile -t nim_httpserver
docker run --rm -it -p 8100:8000 nim_httpserver /root/nim_httpserver2
```
open http://localhost:8100/


## Command Option

- -d 0,1 print debug information