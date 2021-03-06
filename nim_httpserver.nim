import asyncnet
import asyncdispatch
import streams
import os
import net
import strutils
import times
import yaml.serialization, streams
import tables
import parseopt2
import locks
import terminal

import http_tools
import file_service

#
# @see https://nim-lang.org/docs/asyncnet.html
#


type ServerConfig = object
  port : int32
  document_root: string
  hostname: string

var serverConfig1: ServerConfig
var s = newFileStream("config.yml")
load(s, serverConfig1)
s.close()

let DefaultEncode = "utf-8"
let MyPort = serverConfig1.port
let MyHost = serverConfig1.hostname
let DocumentRoot = serverConfig1.document_root
echo "Started at http://", MyHost, ":", MyPort, "/"


const PRINT_DEBUG_SHORT = 1
var debugPrintOn = 0
for kind, key, val in getopt():
  if kind == cmdShortOption and key == "d":
    debugPrintOn = parseInt(val)

var filelogic = file_service.FileService()
filelogic.init()
# var clients {.threadvar.}: seq[AsyncSocket]

var connectedCount = 0
var closedCount = 0

proc processClient(client: AsyncSocket) {.async.} =
  var maxKeepAlive = 100
  while true:
    if client.isClosed:
      break

    if maxKeepAlive < 1:
      client.close()
    
    var requestLines: seq[string] = @[]
    var responseHeaders: seq[string] = @[]
    while true:
      let line = await client.recvLine()
      if line == "" or line == "\r\n":
        break

      requestLines.add(line)
      # echo "[", line, "]"

    if requestLines.len() == 0:
      return
    
    var protocols = split(requestLines[0], " ")
    var method1 = protocols[0]
    var gmtDate = timeToGmtString(getTime())
    if debugPrintOn == PRINT_DEBUG_SHORT:
      echo "Path=", protocols[1]

    var headersTable = initTable[string, string]()
    for i in countup(1, requestLines.len() - 1):
      let line2s = requestLines[i].split(": ")
      headersTable[line2s[0]] = line2s[1]

    if debugPrintOn == PRINT_DEBUG_SHORT:
      echo " HEAD -> ", headersTable
    
    var useKeepAlive = headersTable.contains("Connection") and headersTable["Connection"] == "keep-alive"


    if debugPrintOn == PRINT_DEBUG_SHORT:
      if useKeepAlive:
        echo "KeepAlive -> ", headersTable["Connection"]
      

    var filePath = resolveRealFilePath(protocols[1], DocumentRoot)
    var responseBody:string = nil
    if fileExists(filePath):
      responseBody = filelogic.getFile(filePath)

      responseHeaders.add("HTTP/1.1 200 OK")
      if useKeepAlive:
        responseHeaders.add("Connection: Keep-Alive")
        responseHeaders.add("Keep-Alive: timeout=15, max=" & maxKeepAlive.intToStr())
      else:
        responseHeaders.add("Connection: close")

      responseHeaders.add("Date: " & gmtDate)
      responseHeaders.add("Server: NHS")
      responseHeaders.add("Content-Length: " & responseBody.len().intToStr())

      var contentType = "Content-Type: " & http_tools.decideContentType(filePath, DefaultEncode)
      responseHeaders.add(contentType)

    else:
      responseHeaders.add("HTTP/1.1 404 Not Found")
      responseHeaders.add("Server: NHS")
      responseHeaders.add("Content-Length: 0")
      if useKeepAlive:
        responseHeaders.add("Connection: Keep-Alive")
        responseHeaders.add("Keep-Alive: timeout=15, max=" & maxKeepAlive.intToStr())
      else:
        responseHeaders.add("Connection: close")

    if method1 == "GET" or method1 == "HEAD":
      for line2 in responseHeaders:
        await client.send(line2 & "\r\n")

        if debugPrintOn == PRINT_DEBUG_SHORT:
          echo line2
    
    await client.send("\r\n")

    if responseBody != nil and method1 != "HEAD":
      await client.send(responseBody)
    
    if useKeepAlive:
      maxKeepAlive = maxKeepAlive - 1
    else:
      client.close()
      break

    if debugPrintOn == PRINT_DEBUG_SHORT:
      echo "Finished\n\n\n"


  closedCount = closedCount + 1
  if debugPrintOn == PRINT_DEBUG_SHORT:
    echo "closed"


proc serve() {.async.} =
  var server = newAsyncSocket()
  server.setSockOpt(OptReuseAddr, true)
  server.bindAddr(Port(MyPort))
  server.listen()
  
  while true:
    let client = await server.accept()
    connectedCount = connectedCount + 1
    asyncCheck processClient(client)

var monitorThread: Thread[tuple[]]

proc threadFunc(interval: tuple[]) {.thread.} =
  while true:
    var ymdDate = timeToYmdString(getTime())
    echo ymdDate, " o-", connectedCount, " c-", closedCount

    cursorUp(stdout, 1)
    sleep(1000)

createThread(monitorThread, threadFunc, ())
# joinThreads(thr)
asyncCheck serve()
runForever()
