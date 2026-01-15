import "io" for Stdin

class StackCalc {
  construct new() {
    _stack = []
    _running = true
  }

  run() {
    System.print("Wren-DC (Reverse Polish Notation)")
    System.print("Type numbers to push, ops (+, -, *, /) to calculate, 'p' to print, 'q' to quit.")
    
    while (_running) {
      System.write("> ")
      var input = Stdin.readLine()
      if (input == null) break
      
      var tokens = input.trim().split(" ")
      for (token in tokens) {
        processToken(token)
      }
    }
  }

  processToken(t) {
    if (t == "q") {
      _running = false
    } else if (t == "p") {
      if (_stack.count > 0) System.print(_stack[-1])
    } else if (t == "f") { // Full stack print
      System.print(_stack)
    } else if (["+", "-", "*", "/", "\%"].contains(t)) {
      if (_stack.count < 2) {
        System.print("stack empty")
      } else {
        var b = _stack.removeAt(-1)
        var a = _stack.removeAt(-1)
        if (t == "+") _stack.add(a + b)
        if (t == "-") _stack.add(a - b)
        if (t == "*") _stack.add(a * b)
        if (t == "/") _stack.add(a / b)
        if (t == "\%") _stack.add(a % b)
      }
    } else {
      var num = Num.fromString(t)
      if (num != null) {
        _stack.add(num)
      } else if (t != "") {
        System.print("? unknown token: %(t)")
      }
    }
  }
}

var calc = StackCalc.new()
calc.run()
