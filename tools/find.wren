import "io" for Directory
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

class Find {
  // Start the search from a base directory
  static run(baseDir, pattern) {
    if (!Directory.exists(baseDir)) {
      System.print("find: %(baseDir): No such directory")
      return
    }
    
    // Normalize pattern to lowercase for easier searching
    var searchPattern = ToLower.call(pattern)
    this.search(baseDir, searchPattern)
  }

  // Recursive worker method
  static search(dir, pattern) {
    var entries = Directory.list(dir)

    for (entry in entries) {
      // Create the full relative path
      var fullPath = (dir == "." || dir == "./") ? entry : dir + "/" + entry
      
      // If pattern is empty or name matches pattern, print it
      if (pattern == "" || ToLower.call(entry).contains(pattern)) {
        // ANSI Blue for directories, Reset for files
        if (Directory.exists(fullPath)) {
          System.print("\e[34m%(fullPath)\e[0m")
        } else {
          System.print(fullPath)
        }
      }

      // If it's a directory, go deeper!
      if (Directory.exists(fullPath)) {
        this.search(fullPath, pattern)
      }
    }
  }
}

// --- Usage ---
// Find.run(".", "csv")     // Finds all files containing "csv"
// Find.run(".", "")        // Lists every file and folder recursively
var args = Process.arguments
var pattern = ""
var dir = "."
if (args.count > 0) {
    pattern = args[0]
} 

if(args.count > 1) {
    dir = args[1]
}
Find.run(dir, pattern)
