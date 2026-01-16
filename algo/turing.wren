class TuringMachine {
  construct new(definition) {
    _states = definition["states"]
    _currentState = definition["initialState"]
    _haltState = definition["haltState"]
    _tape = {} // Using a Map to simulate an "infinite" tape
    _head = 0
    
    // Fill initial tape data
    var initialTape = definition["tape"] || ""
    for (i in 0...initialTape.count) {
      _tape[i] = initialTape[i]
    }
  }

  step() {
    if (_currentState == _haltState) return false

    var currentSymbol = _tape[_head] || "_" // "_" represents a blank cell
    var key = "%(_currentState):%(currentSymbol)"
    var rule = _states[key]

    if (!rule) {
      System.print("No rule found for %(key). Halting.")
      return false
    }

    // 1. Write the new symbol
    _tape[_head] = rule["write"]

    // 2. Move the head
    if (rule["move"] == "R") {
      _head = _head + 1
    } else if (rule["move"] == "L") {
      _head = _head - 1
    }

    // 3. Update state
    _currentState = rule["nextState"]
    return true
  }

  printTape() {
    var min = _head
    var max = _head
    for (key in _tape.keys) {
      var k = Num.fromString(key.toString)
      if (k < min) min = k
      if (k > max) max = k
    }

    var s = ""
    for (i in min..max) {
      var char = _tape[i] || "_"
      if (i == _head) {
        s = s + "[%(char)]" // Highlight head position
      } else {
        s = s + " %(char) "
      }
    }
    System.print(s + " | State: %(_currentState)")
  }

  run() {
    while (step()) {
      printTape()
    }
    System.print("Halted in state: %(_currentState)")
  }
}

// --- Problem: Increment a Binary Number ---
// This machine finds the end of a binary string and adds 1, handling carries.
var binaryInc = {
  "initialState": "findEnd",
  "haltState": "halt",
  "tape": "1011", // Binary 11
  "states": {
    "findEnd:0": {"write": "0", "move": "R", "nextState": "findEnd"},
    "findEnd:1": {"write": "1", "move": "R", "nextState": "findEnd"},
    "findEnd:_": {"write": "_", "move": "L", "nextState": "addOne"},
    
    "addOne:1":  {"write": "0", "move": "L", "nextState": "addOne"},
    "addOne:0":  {"write": "1", "move": "R", "nextState": "halt"},
    "addOne:_":  {"write": "1", "move": "R", "nextState": "halt"}
  }
}

var tm = TuringMachine.new(binaryInc)
tm.run()
