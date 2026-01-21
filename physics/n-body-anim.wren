class Body {
  construct new(x, y, vx, vy, mass, char) {
    _pos = [x, y]
    _vel = [vx, vy]
    _mass = mass
    _char = char
  }
  pos { _pos }
  vel { _vel }
  mass { _mass }
  char { _char }
  
  pos=(v) { _pos = v }
  vel=(v) { _vel = v }
}

class SpaceSim {
  construct new() {
    _bodies = [
      Body.new(30, 15, 0, 0, 500, "S"),    // "Sun" (Static-ish)
      Body.new(30, 5, 5, 0, 1, "e"),     // "Earth"
      Body.new(30, 2, 5, 0, 1, "m")    // "Another Planet"
    ]
    _G = 1
    _h = 0.02
  }

  // Calculate accelerations for all bodies
  derivs(state) {
    var deriv = List.filled(state.count, 0)
    
    for (i in 0..._bodies.count) {
      var ax = 0
      var ay = 0
      var xi = state[i * 4]
      var yi = state[i * 4 + 1]
      
      for (j in 0..._bodies.count) {
        if (i == j) continue
        var xj = state[j * 4]
        var yj = state[j * 4 + 1]
        
        var dx = xj - xi
        var dy = yj - yi
        var distSq = dx*dx + dy*dy + 0.1 // Softening factor to prevent infinity
        var dist = distSq.sqrt
        var force = _G * _bodies[j].mass / distSq
        
        ax = ax + force * dx / dist
        ay = ay + force * dy / dist
      }
      
      deriv[i * 4] = state[i * 4 + 2]     // dx = vx
      deriv[i * 4 + 1] = state[i * 4 + 3] // dy = vy
      deriv[i * 4 + 2] = ax               // dvx = ax
      deriv[i * 4 + 3] = ay               // dvy = ay
    }
    return deriv
  }

  update() {
    // Pack state
    var s = []
    for (b in _bodies) {
      s.add(b.pos[0])
      s.add(b.pos[1])
      s.add(b.vel[0])
      s.add(b.vel[1])
    }

    // RK4 Step
    var k1 = derivs(s)
    var k2 = derivs(vecAdd(s, vecMult(k1, _h/2)))
    var k3 = derivs(vecAdd(s, vecMult(k2, _h/2)))
    var k4 = derivs(vecAdd(s, vecMult(k3, _h)))

    var delta = vecMult(vecAdd(vecAdd(k1, vecMult(k2, 2)), vecAdd(vecMult(k3, 2), k4)), _h/6)
    var newState = vecAdd(s, delta)

    // Unpack state
    for (i in 0..._bodies.count) {
      _bodies[i].pos = [newState[i * 4], newState[i * 4 + 1]]
      _bodies[i].vel = [newState[i * 4 + 2], newState[i * 4 + 3]]
    }
  }

  vecAdd(a, b) {
    var r = []
    for (i in 0...a.count) r.add(a[i] + b[i])
    return r
  }

  vecMult(v, s) {
    var r = []
    for (i in 0...v.count) r.add(v[i] * s)
    return r
  }

  draw() {
    var width = 60
    var height = 30
    var grid = List.filled(height + 1, null)
    for (i in 0..height) grid[i] = List.filled(width + 1, " ")

    for (b in _bodies) {
      var x = b.pos[0].round
      var y = b.pos[1].round
      if (x >= 0 && x <= width && y >= 0 && y <= height) {
        grid[y][x] = b.char
      }
    }

    System.write("\u001b[2J\u001b[H")
    System.print("--- N-Body Orbital Mechanics (RK4) ---")
    for (row in grid) System.print(row.join(""))
  }

  run() {
    while (true) {
      draw()
      update()
      var start = System.clock
      while (System.clock - start < 0.016) {}
    }
  }
}

SpaceSim.new().run()
