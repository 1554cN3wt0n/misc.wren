class DoublePendulum {
  construct new() {
    // theta1, omega1, theta2, omega2
    // 0 is straight down. 3.14 (PI) is straight up.
    _state = [1.5, 0.0, 1.5, 0.0]
    
    _m1 = 1.0
    _m2 = 1.0
    _L1 = 8.0  // Length in characters
    _L2 = 8.0
    _g = 9.81
    
    _h = 0.01  // MUCH smaller step for stability
    _t = 0
  }

  derivs(t, s) {
    var t1 = s[0]
    var w1 = s[1]
    var t2 = s[2]
    var w2 = s[3]

    var m1 = _m1
    var m2 = _m2
    var L1 = _L1
    var L2 = _L2
    var g = _g

    // The denominator is the most sensitive part of the physics
    var num1 = -g * (2 * m1 + m2) * t1.sin
    var num2 = -m2 * g * (t1 - 2 * t2).sin
    var num3 = -2 * (t1 - t2).sin * m2
    var num4 = w2 * w2 * L2 + w1 * w1 * L1 * (t1 - t2).cos
    var den = L1 * (2 * m1 + m2 - m2 * (2 * t1 - 2 * t2).cos)
    var a1 = (num1 + num2 + num3 * num4) / den

    var num5 = 2 * (t1 - t2).sin
    var num6 = (w1 * w1 * L1 * (m1 + m2))
    var num7 = g * (m1 + m2) * t1.cos
    var num8 = w2 * w2 * L2 * m2 * (t1 - t2).cos
    var den2 = L2 * (2 * m1 + m2 - m2 * (2 * t1 - 2 * t2).cos)
    var a2 = (num5 * (num6 + num7 + num8)) / den2

    return [w1, a1, w2, a2]
  }

  update() {
    // Perform 5 sub-steps per frame to keep it smooth but stable
    for (i in 0..5) {
      var y = _state
      var k1 = derivs(_t, y)
      var k2 = derivs(_t + _h/2, add(y, mult(k1, _h/2)))
      var k3 = derivs(_t + _h/2, add(y, mult(k2, _h/2)))
      var k4 = derivs(_t + _h,   add(y, mult(k3, _h)))

      var delta = mult(add(add(k1, mult(k2, 2)), add(mult(k3, 2), k4)), _h/6)
      _state = add(_state, delta)
      _t = _t + _h
    }
  }

  add(a, b) { [a[0]+b[0], a[1]+b[1], a[2]+b[2], a[3]+b[3]] }
  mult(v, s) { [v[0]*s, v[1]*s, v[2]*s, v[3]*s] }

  draw() {
    var width = 60
    var height = 35
    var cx = 30
    var cy = 15 // Center the pivot vertically

    var x1 = (cx + _L1 * _state[0].sin).round
    var y1 = (cy + _L1 * _state[0].cos).round
    var x2 = (x1 + _L2 * _state[2].sin).round
    var y2 = (y1 + _L2 * _state[2].cos).round

    System.write("\u001b[2J\u001b[H")
    System.print("Double Pendulum (RK4 Sub-stepping)")
    
    for (y in 0..height) {
      var row = ""
      for (x in 0..width) {
        if (x == cx && y == cy) {
            row = row + "O"
        } else if (x == x1 && y == y1) {
            row = row + "o"
        } else if (x == x2 && y == y2) {
            row = row + "@"
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
      while (System.clock - start < 0.016) {} // ~60fps
    }
  }
}

DoublePendulum.new().run()
