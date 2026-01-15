import "io" for File, Stdin 
import "os" for Process

class Less {
  construct new(filename) {
    if (!File.exists(filename)) {
      Fiber.abort("File not found: %(filename)")
    }
    _lines = File.read(filename).split("\n")
    _pageSize = 20
    _currentLine = 0
    _totalLines = _lines.count
  }

  run() {
    while (_currentLine < _totalLines) {
      displayPage()
      
      if (_currentLine >= _totalLines) {
        System.print("(END)")
        break
      }

      System.write("\e[7m--More-- (%((_currentLine / _totalLines * 100).floor)\%)\e[0m")
      
      var input = Stdin.readLine()
      
      if (input == "q") {
        break
      } else if (input == "h") {
        showHelp()
      }
      // Pressing Enter simply continues the loop to the next displayPage()
    }
  }

  displayPage() {
    // Clear the current line (the --More-- prompt)
    System.write("\e[2K\r") 
    
    var end = (_currentLine + _pageSize).min(_totalLines)
    for (i in _currentLine...end) {
      System.print(_lines[i])
    }
    _currentLine = end
  }

  showHelp() {
    System.print("\nCommands: [Enter] Next Page | [q] Quit | [h] Help")
  }
}

// Usage:
// Pass the filename as an argument or hardcode it for testing
var args = Process.arguments 
var pager = Less.new(args[0])
pager.run()
