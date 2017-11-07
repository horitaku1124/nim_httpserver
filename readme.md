# Nim http server

## Run

```
nimble install yaml
nim c -r server.nim
```


## Test on docker
```
cd docker
docker build ../ -f Dockerfile -n nim_httpserver
docker run -it nim_httpserver /root/nim_httpserver
```