import strutils
import times

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

proc timeToGmtString(time: Time): string = return time.getGMTime().format("ddd, dd MMM yyyy HH:mm:ss ") & "GMT"


proc timeToYmdString(time: Time): string = return time.getLocalTime().format("yyyy-MM-dd HH:mm:ss")


proc resolveRealFilePath(uri:string, document_roor:string) : string =
  var path = uri
  if path.endsWith("/"):
    path.add("index.html")
    
  return document_roor & path

export decideContentType
export timeToGmtString
export timeToYmdString
export resolveRealFilePath