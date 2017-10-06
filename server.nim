import net

var socket = newSocket()
socket.bindAddr(Port(8000),"127.0.0.1")
socket.listen()

var client = newSocket()
var address = ""
var lineBuff = ""
while true:
  socket.acceptAddr(client, address)

  client.readLine(lineBuff)
  echo lineBuff
  client.send("HTTP 200 OK\r\n\r\n")
  client.close()

socket.close()
echo "Closed Socket"