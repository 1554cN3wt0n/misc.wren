import "io" for Stdin, Stdout

class Brainfuck {
  construct new(code) {
    _code = code
    _tape = List.filled(30000, 0) // Standard tape size
    _ptr = 0                      // Data pointer
    _pc = 0                       // Program counter
    
    // Pre-calculate loop jumps for performance
    _jumps = {}
    buildJumpTable()
  }

  buildJumpTable() {
    var stack = []
    for (i in 0..._code.count) {
      var char = _code[i]
      if (char == "[") {
        stack.add(i)
      } else if (char == "]") {
        if (stack.isEmpty) Fiber.abort("Mismatched brackets: extra ']' at %(i)")
        var start = stack.removeAt(-1)
        _jumps[start] = i
        _jumps[i] = start
      }
    }
    if (!stack.isEmpty) Fiber.abort("Mismatched brackets: unclosed '[' at %(stack[-1])")
  }

  run() {
    while (_pc < _code.count) {
      var cmd = _code[_pc]

      if (cmd == ">") {
        _ptr = _ptr + 1
      } else if (cmd == "<") {
        _ptr = _ptr - 1
      } else if (cmd == "+") {
        _tape[_ptr] = (_tape[_ptr] + 1) % 256
      } else if (cmd == "-") {
        _tape[_ptr] = (_tape[_ptr] - 1) % 256
      } else if (cmd == ".") {
        System.write(String.fromByte(_tape[_ptr]))
      } else if (cmd == ",") {
        _tape[_ptr] = Stdin.readByte()
      } else if (cmd == "[") {
        if (_tape[_ptr] == 0) _pc = _jumps[_pc]
      } else if (cmd == "]") {
        if (_tape[_ptr] != 0) _pc = _jumps[_pc]
      }
      
      _pc = _pc + 1
    }
  }
}

// --- Test: Hello World! ---
var helloWorld = "++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++."

var bf = Brainfuck.new(helloWorld)
System.print("Executing Brainfuck:")
bf.run()
System.print("\nDone.")
