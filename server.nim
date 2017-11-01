import net
import strutils

var MyPort = 8000
var MyHost = "127.0.0.1"
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
  
  responseHeaders.add("HTTP 200 OK")
  responseHeaders.add("Connection: close")
  
  for line in responseHeaders:
    client.send(line)
    client.send("\r\n")

  client.send("\r\n")
  client.close()
  echo "closed"

socket.close()
echo "Closed Socket"