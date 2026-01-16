var ToUpper = Fn.new { |str| 
  var out = ""
  for (c in str.bytes) {
    if (c >= 97 && c <= 122) {
      out = out + String.fromByte(c - 32)
    } else {
      out = out + String.fromByte(c)
    }
  }
  return out
}

class Assembler {
  construct new(program) {
    _lines = program.split("\n").map { |l| l.trim() }.where { |l| l != "" && !l.startsWith(";") }.toList
    _regs = { "R0": 0, "R1": 0, "R2": 0, "R3": 0 }
    _memory = List.filled(64, 0)
    _ip = 0
    _labels = {}
    _halted = false
    
    findLabels()
  }

  // Pre-scan the code to find label positions (e.g. "loop:")
  findLabels() {
    for (i in 0..._lines.count) {
      if (_lines[i].endsWith(":")) {
        var labelName = _lines[i].replace(":", "")
        _labels[labelName] = i
      }
    }
  }

  // Helper to get value of a register or a literal number
  getValue(op) {
    if (_regs.containsKey(op)) return _regs[op]
    return Num.fromString(op)
  }

  step() {
    if (_ip >= _lines.count || _halted) return
    
    var line = _lines[_ip]
    if (line.endsWith(":")) { // Skip labels
      _ip = _ip + 1
      return
    }

    var parts = line.split(" ").where { |p| p != "" }.toList
    var instr = ToUpper.call(parts[0])
    
    if (instr == "MOV") { // MOV R0 10
      _regs[parts[1]] = getValue(parts[2])
    } else if (instr == "ADD") { // ADD R0 R1
      _regs[parts[1]] = _regs[parts[1]] + getValue(parts[2])
    } else if (instr == "SUB") { // SUB R0 1
      _regs[parts[1]] = _regs[parts[1]] - getValue(parts[2])
    } else if (instr == "JMP") { // JMP start
      _ip = _labels[parts[1]]
      return // Don't increment IP
    } else if (instr == "JZ") { // Jump if Zero
      if (_regs[parts[1]] == 0) {
        _ip = _labels[parts[2]]
        return
      }
    } else if (instr == "PRT") { // Print register
      System.print("Output: " + getValue(parts[1]).toString)
    } else if (instr == "HLT") {
      _halted = true
    }

    _ip = _ip + 1
  }

  run() {
    while (!_halted && _ip < _lines.count) {
      step()
    }
  }
}

// --- Example Program: Countdown from 5 ---
var code = "
MOV R0 5
loop:
PRT R0
SUB R0 1
JZ R0 end
JMP loop
end:
PRT R0
HLT
"

var vm = Assembler.new(code)
vm.run()
