# Nim http server

## Run

```
nimble install yaml
nim c -r server.nim
```


## Test on docker
```
cd docker
docker build ../ -f Dockerfile -t nim_httpserver
docker run -it -p 8100:8000 nim_httpserver /root/nim_httpserver
```
open http://localhost:8100/