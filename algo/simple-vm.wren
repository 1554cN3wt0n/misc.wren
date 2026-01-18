// OpCodes: These are the "Machine Code" of our VM
class Op {
  static PUSH { 0 }
  static ADD  { 1 }
  static SUB  { 2 }
  static MUL  { 3 }
  static PRINT { 4 }
  static HALT  { 5 }
  static STORE { 6 } // STORE <index>
  static LOAD  { 7 } // LOAD <index>
}

class VM {
  construct new(bytecode) {
    _code = bytecode
    _stack = []
    _globals = List.filled(10, 0) // Simple fixed-size memory
    _ip = 0 // Instruction Pointer
  }

  run() {
    while (_ip < _code.count) {
      var instr = _code[_ip]
      _ip = _ip + 1

      if (instr == Op.PUSH) {
        var val = _code[_ip]
        _ip = _ip + 1
        _stack.add(val)

      } else if (instr == Op.ADD) {
        var b = _stack.removeAt(-1)
        var a = _stack.removeAt(-1)
        _stack.add(a + b)

      } else if (instr == Op.MUL) {
        var b = _stack.removeAt(-1)
        var a = _stack.removeAt(-1)
        _stack.add(a * b)

      } else if (instr == Op.STORE) {
        var addr = _code[_ip]
        _ip = _ip + 1
        _globals[addr] = _stack.removeAt(-1)

      } else if (instr == Op.LOAD) {
        var addr = _code[_ip]
        _ip = _ip + 1
        _stack.add(_globals[addr])

      } else if (instr == Op.PRINT) {
        System.print(_stack.removeAt(-1))

      } else if (instr == Op.HALT) {
        break
      }
    }
  }
}

// --- Manually Compiled Program ---
// Goal: x = 5 * 10; print x + 2;
var program = [
  Op.PUSH, 5,
  Op.PUSH, 10,
  Op.MUL,
  Op.STORE, 0,    // x is at address 0
  Op.LOAD, 0,
  Op.PUSH, 2,
  Op.ADD,
  Op.PRINT,
  Op.HALT
]

var vm = VM.new(program)
vm.run() // Output: 52
