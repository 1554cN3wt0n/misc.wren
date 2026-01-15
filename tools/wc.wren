import "io" for File
import "os" for Process

class WordCount {
  static run(filename) {
    if (!File.exists(filename)) {
      System.print("wc: %(filename): No such file")
      return
    }

    var content = File.read(filename)
    var bytes = content.bytes
    
    var lines = 0
    var words = 0
    var byteCount = bytes.count
    var inWord = false

    for (b in bytes) {
      // 1. Count Newlines (ASCII 10 is '\n')
      if (b == 10) lines = lines + 1

      // 2. Count Words by detecting transitions
      // Whitespace check: space (32), tab (9), newline (10), carriage return (13)
      var isSpace = (b == 32 || b == 9 || b == 10 || b == 13)
      
      if (isSpace) {
        inWord = false
      } else if (!inWord) {
        inWord = true
        words = words + 1
      }
    }

    // Format output like the original: lines, words, bytes, filename
    System.print("%(lines) %(words) %(byteCount) %(filename)")
  }
}


// Usage:
// WordCount.run("main.wren")
var args = Process.arguments
 WordCount.run(args[0])
