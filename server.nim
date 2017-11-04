import net
import strutils
import streams
import os

import http

var DefaultEncode = "utf-8"
var MyPort = 8000
var MyHost = "127.0.0.1"
var DocumentRoot = "./public_html"
var socket = newSocket()
socket.bindAddr(Port(MyPort), MyHost)
socket.listen()



var client = newSocket()
var address = ""
var lineBuff = ""
echo "Started at http://", MyHost, ":", MyPort, "/"
while true:
  echo "wait"
  socket.acceptAddr(client, address)

  var requestLines: seq[string] = @[]
  var responseHeaders: seq[string] = @[]
  while true:
    client.readLine(lineBuff)
    if lineBuff == "":
      break

    if lineBuff == "\r\n":
      break

    requestLines.add(lineBuff)
    echo "[", lineBuff, "]"

  if requestLines.len() == 0:
    continue

  var protocols = split(requestLines[0], " ")
  var method1 = protocols[0]
  var path = protocols[1]
  echo "Path=", path
  if path.endsWith("/"):
    path.add("index.html")

  var filePath = DocumentRoot
  filePath.add(path)
  var responseBody:string = nil
  if fileExists(filePath):
    var fs = newFileStream(filePath, fmRead)
    responseBody = fs.readAll()

    responseHeaders.add("HTTP 200 OK")
    responseHeaders.add("Connection: close")
    responseHeaders.add("Server: NHS")
    responseHeaders.add("Content-Length: " & responseBody.len().intToStr())

    
    var contentType = "Content-Type: "
    contentType = contentType & http.decideContentType(filePath, DefaultEncode)
    echo contentType
    responseHeaders.add(contentType)

  else:
    responseHeaders.add("HTTP 404 Not Found")
    responseHeaders.add("Server: NHS")
    responseHeaders.add("Connection: close")



  # echo protocols
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