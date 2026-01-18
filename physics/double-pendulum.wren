class DoublePendulum {
  construct new() {
    // Physical constants
    _g = 9.81   // Gravity
    _m1 = 10    // Mass of arm 1
    _m2 = 10    // Mass of arm 2
    _l1 = 100   // Length of arm 1
    _l2 = 100   // Length of arm 2
    
    // Initial State (Angles in radians, 3.14/2 = 90 degrees)
    _a1 = 1.57  // Angle 1
    _a2 = 1.57  // Angle 2
    _a1_v = 0   // Angular velocity 1
    _a2_v = 0   // Angular velocity 2
    
    _dt = 0.05  // Time step
  }

  step() {
    // Complex equations for angular acceleration (a_alpha)
    // derived from the Lagrangian of a double pendulum
    
    var num1 = -_g * (2 * _m1 + _m2) * _a1.sin
    var num2 = -_m2 * _g * (_a1 - 2 * _a2).sin
    var num3 = -2 * (_a1 - _a2).sin * _m2
    var num4 = _a2_v * _a2_v * _l2 + _a1_v * _a1_v * _l1 * (_a1 - _a2).cos
    var den = _l1 * (2 * _m1 + _m2 - _m2 * (2 * _a1 - 2 * _a2).cos)
    var a1_a = (num1 + num2 + num3 * num4) / den

    num1 = 2 * (_a1 - _a2).sin
    num2 = (_a1_v * _a1_v * _l1 * (_m1 + _m2))
    num3 = _g * (_m1 + _m2) * _a1.cos
    num4 = _a2_v * _a2_v * _l2 * _m2 * (_a1 - _a2).cos
    den = _l2 * (2 * _m1 + _m2 - _m2 * (2 * _a1 - 2 * _a2).cos)
    var a2_a = (num1 * (num2 + num3 + num4)) / den

    // Update Velocities
    _a1_v = _a1_v + a1_a * _dt
    _a2_v = _a2_v + a2_a * _dt
    
    // Update Angles
    _a1 = _a1 + _a1_v * _dt
    _a2 = _a2 + _a2_v * _dt
    
    // Optional: Add a tiny bit of friction to keep it from exploding
    _a1_v = _a1_v * 0.999
    _a2_v = _a2_v * 0.999
  }

  // Convert angles to X,Y coordinates for visualization
  getPositions() {
    var x1 = _l1 * _a1.sin
    var y1 = _l1 * _a1.cos
    var x2 = x1 + _l2 * _a2.sin
    var y2 = y1 + _l2 * _a2.cos
    return [[x1, y1], [x2, y2]]
  }

  run(iterations) {
    for (i in 0...iterations) {
      step()
      if (i % 20 == 0) {
        var pos = getPositions()
        var p2 = pos[1]
        System.print("Step %(i.toString) | Tip X: %(p2[0].toString) | Tip Y: %(p2[1].toString)")
      }
    }
  }
}

var sim = DoublePendulum.new()
sim.run(400)
