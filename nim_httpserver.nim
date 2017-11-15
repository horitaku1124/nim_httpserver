import net
import strutils
import streams
import os
import times

# import zip # nimble install zip -y 
import yaml.serialization, streams

import http_tools

type ServerConfig = object
  port : int32
  document_root: string
  hostname: string


var serverConfig1: ServerConfig
var s = newFileStream("config.yml")
load(s, serverConfig1)
s.close()

const DefaultEncode = "utf-8"
var MyPort = serverConfig1.port
var MyHost = serverConfig1.hostname
var DocumentRoot = serverConfig1.document_root
var socket = newSocket()
socket.bindAddr(Port(MyPort))
socket.listen()


var client = newSocket()
echo "Started at http://", MyHost, ":", MyPort, "/"
while true:
  echo "wait"
  var address = ""
  socket.acceptAddr(client, address)

  var requestLines: seq[string] = @[]
  var responseHeaders: seq[string] = @[]
  var lineBuff = ""
  while true:
    client.readLine(lineBuff)
    if lineBuff == "" or lineBuff == "\r\n":
      break

    requestLines.add(lineBuff)
    echo "[", lineBuff, "]"

  if requestLines.len() == 0:
    continue

  var protocols = split(requestLines[0], " ")
  var method1 = protocols[0]
  var gmtDate = timeToGmtString(getTime())
  echo "Path=", protocols[1]

  var filePath = resolveRealFilePath(protocols[1], DocumentRoot)
  var responseBody:string = nil
  if fileExists(filePath):
    var fs = newFileStream(filePath, fmRead)
    responseBody = fs.readAll()

    responseHeaders.add("HTTP/1.1 200 OK")
    responseHeaders.add("Connection: close")
    responseHeaders.add("Date: " & gmtDate)
    responseHeaders.add("Server: NHS")
    responseHeaders.add("Content-Length: " & responseBody.len().intToStr())

    var contentType = "Content-Type: " & http_tools.decideContentType(filePath, DefaultEncode)
    responseHeaders.add(contentType)

  else:
    responseHeaders.add("HTTP/1.1 404 Not Found")
    responseHeaders.add("Server: NHS")
    responseHeaders.add("Connection: close")


  # echo "Method:", method1
  if method1 == "GET" or method1 == "HEAD":
    for line in responseHeaders:
      client.send(line)
      client.send("\r\n")
  
  client.send("\r\n")

  if responseBody != nil and method1 != "HEAD":
    client.send(responseBody)

  client.close()
  echo "closed"

socket.close()
echo "Closed Socket"