import strutils

proc decideContentType(filePath:string, defaultEncode:string):string = 

  var contentType:string
  if filePath.endsWith(".html"):
    contentType = "text/html; " & defaultEncode
  elif filePath.endsWith(".js"):
    contentType = "application/javascript; " & defaultEncode
  elif filePath.endsWith(".png"):
    contentType = "image/png"
  elif filePath.endsWith(".jpg") or filePath.endsWith(".jpeg"):
    contentType = "image/jpeg"
  else:
    contentType = "application/octet-stream"
  return contentType


export decideContentType