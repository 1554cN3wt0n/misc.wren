class WaveSim {
  construct new() {
    _width = 50
    _height = 20
    
    // Each point has [position, velocity]
    // We initialize the string in the middle
    _nodes = []
    for (i in 0.._width) {
      _nodes.add([0.0, 0.0]) 
    }
    
    _tension = 0.15
    _damping = 0.98
    _time = 0
  }

  update() {
    _time = _time + 0.1
    
    // 1. Manual "Pluck": Move the first node in a Sine wave
    _nodes[0][0] = (_time * 1.5).sin * 6
    
    // 2. Calculate neighbor forces
    var newNodes = []
    for (i in 0.._width) {
      var currentY = _nodes[i][0]
      var currentV = _nodes[i][1]
      
      // Fixed ends (except the first node which we control)
      if (i == 0) {
        newNodes.add([currentY, 0])
        continue
      }
      if (i == _width) {
        newNodes.add([0, 0])
        continue
      }

      // Force from left and right neighbors
      var leftY = _nodes[i-1][0]
      var rightY = _nodes[i+1][0]
      
      var acceleration = _tension * (leftY + rightY - 2 * currentY)
      
      var vNext = (currentV + acceleration) * _damping
      var yNext = currentY + vNext
      
      newNodes.add([yNext, vNext])
    }
    _nodes = newNodes
  }

  draw() {
    var midY = (_height / 2).floor
    System.write("\u001b[2J\u001b[H")
    System.print("--- Wren String Wave Simulation ---")
    System.print(" (The left side is being vibrated) ")

    for (y in 0.._height) {
      var row = ""
      for (x in 0.._width) {
        var nodeY = (_nodes[x][0] + midY).round
        if (y == nodeY) {
          row = row + "~"
        } else if (y == midY && x % 5 == 0) {
          row = row + "-" // Center line guide
        } else {
          row = row + " "
        }
      }
      System.print(row)
    }
  }

  run() {
    while (true) {
      draw()
      update()
      var start = System.clock
      while (System.clock - start < 0.03) {}
    }
  }
}

WaveSim.new().run()
