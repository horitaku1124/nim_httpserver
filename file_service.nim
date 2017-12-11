import tables
import streams

type FileService = ref object of RootObj
  filePathCache: Table[string, string]

method init(this: FileService): void {.base.} =
  this.filePathCache = initTable[string, string]()

method getFile(this: FileService, filePath: string): string {.base.} =
  var fileData:string
  if this.filePathCache.contains(filePath):
    fileData = this.filePathCache[filePath]

    # if debugPrintOn == PRINT_DEBUG_SHORT:
    # echo "in cache"
  else:
    let fs = newFileStream(filePath, fmRead)
    fileData = fs.readAll()
    fs.close()
    this.filePathCache[filePath] = fileData
  return fileData


export FileService
export init
export getFile