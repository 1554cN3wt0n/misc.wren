class PendulumAnim {
  construct new() {
    // Initial state: [angle, angular_velocity]
    _state = [1.2, 0.0] 
    _g = 9.81
    _L = 1.0
    _t = 0
    _h = 0.05 // Time step
  }

  // Derivative function: f(t, y)
  derivs(t, y) {
    var theta = y[0]
    var omega = y[1]
    return [omega, -(_g / _L) * theta.sin]
  }

  // RK4 Logic (Internalized for the animation)
  update() {
    var y = _state
    var k1 = derivs(_t, y)
    var k2 = derivs(_t + _h/2, add(y, mult(k1, _h/2)))
    var k3 = derivs(_t + _h/2, add(y, mult(k2, _h/2)))
    var k4 = derivs(_t + _h,   add(y, mult(k3, _h)))

    var delta = mult(add(add(k1, mult(k2, 2)), add(mult(k3, 2), k4)), _h/6)
    _state = add(_state, delta)
    _t = _t + _h
  }

  // Vector helpers
  add(a, b) { [a[0] + b[0], a[1] + b[1]] }
  mult(v, s) { [v[0] * s, v[1] * s] }

  draw() {
    var width = 40
    var height = 20
    var centerX = 20
    var centerY = 2
    var armLength = 15

    // Calculate bob position
    var theta = _state[0]
    var bobX = (centerX + theta.sin * armLength).round
    var bobY = (centerY + theta.cos * armLength).round

    // Clear screen and reset cursor
    System.write("\u001b[2J\u001b[H")
    System.print("--- Wren RK4 Pendulum ---")
    
    for (y in 0..height) {
      var row = ""
      for (x in 0..width) {
        if (x == centerX && y == centerY) {
          row = row + "O" // The pivot
        } else if (x == bobX && y == bobY) {
          row = row + "@" // The bob
        } else {
          row = row + " "
        }
      }
      System.print(row)
    }
    System.print("Angle: %(_state[0])")
  }

  run() {
    while (true) {
      draw()
      update()
      
      // Small delay for smooth animation
      var start = System.clock
      while (System.clock - start < 0.03) {}
    }
  }
}

var anim = PendulumAnim.new()
anim.run()
