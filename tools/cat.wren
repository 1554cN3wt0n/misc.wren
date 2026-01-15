import "io" for File, Stdin
import "os" for Process

class Cat {
  // Main method to handle one or more files
  static run(filenames, showNumbers) {
    if (filenames.count == 0) {
      // If no files, read from Stdin (standard Unix behavior)
      this.streamStdin()
      return
    }

    for (filename in filenames) {
      if (!File.exists(filename)) {
        System.print("cat: %(filename): No such file")
        continue
      }
      
      this.printFile(filename, showNumbers)
    }
  }

  static printFile(filename, showNumbers) {
    var content = File.read(filename)
    var lines = content.split("\n")
    
    for (i in 0...lines.count) {
      if (showNumbers) {
        // Formats line numbers similar to 'cat -n'
        var num = (i + 1).toString
        System.write(num + "  " * (6 - num.count))
      }
      System.print(lines[i])
    }
  }

  // Reads from terminal until Ctrl+D (null)
  static streamStdin() {
    while (true) {
      var line = Stdin.readLine()
      if (line == null) break
      System.print(line)
    }
  }
}


// --- Usage Examples ---
// Cat.run(["file1.txt", "file2.txt"], false) // Merges two files
// Cat.run(["script.wren"], true)             // Prints with line numbers
var args = Process.arguments
Cat.run(args, true)
