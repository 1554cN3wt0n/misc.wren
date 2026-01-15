import "io" for Directory, File
import "os" for Process

class Ls {
  static run(path, longFormat) {
    if (!Directory.exists(path)) {
      System.print("ls: %(path): No such directory")
      return
    }

    var entries = Directory.list(path)
    
    if (!longFormat) {
      // Simple format: list names horizontally or in a column
      for (entry in entries) {
        System.write(entry + "  ")
      }
      System.print("") // Final newline
    } else {
      // Long format: show details
      System.print("Total items: %(entries.count)")
      for (entry in entries) {
        var fullPath = path + "/" + entry
        var info = " [FILE] "
        var size = "0"
        
        // Check if it's a directory or file
        if (Directory.exists(fullPath)) {
          info = " [DIR]  "
        } else {
          // Getting file size (this depends on the environment)
          size = File.read(fullPath).count.toString
        }
        
        System.print("%(info) %(size) bytes  %(entry)")
      }
    }
  }
}


// --- Usage ---
// Ls.run(".", false) // Standard list
// Ls.run(".", true)  // Long list with sizes
var args = Process.arguments
if (args.count > 0) {
  Ls.run(args[0], true)
} else {
  Ls.run(".", true)  // Long list with sizes
}
