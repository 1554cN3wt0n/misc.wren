import "io" for Stdin, File

class Ed {
  construct new() {
    _buffer = []
    _dot = 0          // current line (1-based, like real ed)
    _running = true
    _filename = ""
  }

  run() {
    while (_running) {
      var input = Stdin.readLine()
      if (input == null) break
      execute(input.trim())
    }
  }

  // -----------------------------
  // Command parsing
  // -----------------------------
  execute(cmd) {
    if (cmd == "") {
      printNext()
      return
    }

    var addr = parseAddress(cmd)
    var rest = addr["rest"]
    
    if (rest == "") {
      printLine(addr["value"], false)
      return
    } 

    if (rest == "q") {
      _running = false
    } else if (rest == "p") {
      printLine(addr["valuei"], false)
    } else if (rest == "n") {
      printLine(addr["value"], true)
    } else if (rest == "a") {
      appendAfter(addr["value"])
    } else if (rest == "d") {
      deleteLine(addr["value"])
    } else if (rest.startsWith("e")) {
      editFile(rest[1..-1].trim())
    } else if (rest.startsWith("w")) {
      writeFile(rest[1..-1].trim())
    } else if (rest == "i") {
      insertBefore(addr["value"])
    } else if (rest == "c") {
      changeLine(addr["value"])
    } else {
      error()
    }
  }

  // -----------------------------
  // Address handling
  // -----------------------------
  parseAddress(cmd) {
    if (cmd.isEmpty) return { "value": _dot, "rest": "" }

    var c = cmd[0]
    if (c == ".") return { "value": _dot, "rest": cmd[1..-1].trim() }
    if (c == "$") return { "value": _buffer.count, "rest": cmd[1..-1].trim() }

    var n = Num.fromString(cmd)
    if (n != null) {
      return { "value": n, "rest": cmd[n.toString.count..-1].trim() }
    }

    return { "value": _dot, "rest": cmd }
  }

  // -----------------------------
  // Commands
  // -----------------------------
  printLine(n, numbered) {
    if (!validLine(n)) return error()
    _dot = n
    var line = _buffer[n - 1]
    if (numbered) {
      System.print("%(n)\t%(line)")
    } else {
      System.print(line)
    }
  }

  printNext() {
    if (_dot >= _buffer.count) return error()
    printLine(_dot + 1, false)
  }

  appendAfter(n) {
    if (n < 0 || n > _buffer.count) return error()
    _dot = n

    while (true) {
      var line = Stdin.readLine()
      if (line == ".") break
      _buffer.insert(_dot, line)
      _dot = _dot + 1
    }
  }

  deleteLine(n) {
    if (!validLine(n)) return error()
    _buffer.removeAt(n - 1)
    if (_buffer.count == 0) {
      _dot = 0
    } else if (n > _buffer.count) {
      _dot = _buffer.count
    } else {
      _dot = n
    }
  }

  editFile(name) {
    if (name == "") return error()
    if (!File.exists(name)) return error()

    var text = File.read(name)
    _buffer = text.split("\n")
    _dot = _buffer.count
    _filename = name
    System.print("%(text.count) bytes")
  }

  writeFile(name) {
    if (name == "") name = _filename
    if (name == "") return error()

    var content = _buffer.join("\n")
    File.create(name) {|f| f.writeBytes(content) }
    _filename = name
    System.print("%(content.count) bytes")
  }
  
  insertBefore(n) {
    if (n < 1 || n > _buffer.count + 1) return error()
    _dot = n - 1
  
    while (true) {
      var line = Stdin.readLine()
      if (line == ".") break
      _buffer.insert(_dot, line)
      _dot = _dot + 1
    }
  }

  changeLine(n) {
    if (!validLine(n)) return error()
    deleteLine(n)
    insertBefore(n)
  }

  // -----------------------------
  // Helpers
  // -----------------------------
  validLine(n) {
    return n >= 1 && n <= _buffer.count
  }

  error() {
    System.print("?")
  }
}

// Start editor
Ed.new().run()

