import "io" for File
import "os" for Process

var ToLower = Fn.new { |str| 
  var out = ""
  for (c in str.bytes) {
    if (c >= 65 && c <= 90) {
      out = out + String.fromByte(c + 32)
    } else {
      out = out + String.fromByte(c)
    }
  }
  return out
}


class Grep {
  static run(pattern, filename, ignoreCase) {
    if (!File.exists(filename)) {
      System.print("File not found.")
      return
    }

    var content = File.read(filename)
    var lines = content.split("\n")
    var searchPattern = ignoreCase ? ToLower.call(pattern) : pattern

    for (i in 0...lines.count) {
      var line = lines[i]
      var checkLine = ignoreCase ? ToLower.call(line) : line
      
      if (checkLine.contains(searchPattern)) {
        // ANSI yellow for the line number, green for the match
        System.print("\e[33m%(i + 1):\e[0m %(line)")
      }
    }
  }
}

var args = Process.arguments
// Usage: Grep.run("LinearLayer", "my_model.wren", true)
Grep.run(args[0], args[1], true)
