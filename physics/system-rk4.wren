var PadEnd = Fn.new { |str, size|
    if (str.count >= size) return str
    return str + " " * (size - str.count)
}

class SystemSolver {
  construct new(df) {
    _df = df
  }

  // Performs RK4 on a List of values
  step(t, y, h) {
    var k1 = _df.call(t, y)
    
    var k2 = _df.call(t + h/2, addVectors(y, multiplyVector(k1, h/2)))
    var k3 = _df.call(t + h/2, addVectors(y, multiplyVector(k2, h/2)))
    var k4 = _df.call(t + h,   addVectors(y, multiplyVector(k3, h)))

    // y_next = y + (h/6)*(k1 + 2*k2 + 2*k3 + k4)
    var weightedSum = addVectors(k1, multiplyVector(k2, 2))
    weightedSum = addVectors(weightedSum, multiplyVector(k3, 2))
    weightedSum = addVectors(weightedSum, k4)
    
    return addVectors(y, multiplyVector(weightedSum, h/6))
  }

  // Helper: Vector Addition (A + B)
  addVectors(a, b) {
    var res = []
    for (i in 0...a.count) res.add(a[i] + b[i])
    return res
  }

  // Helper: Scalar Multiplication (V * s)
  multiplyVector(v, s) {
    var res = []
    for (i in 0...v.count) res.add(v[i] * s)
    return res
  }

  solve(y0, tStart, tEnd, steps) {
    var h = (tEnd - tStart) / steps
    var t = tStart
    var y = y0

    for (i in 0..steps) {
      System.print("T: %(PadEnd.call(t.toString, 6)) | State: %(y)")
      y = step(t, y, h)
      t = t + h
    }
  }
}

// --- Pendulum Example ---
// State vector y = [theta, omega]
// constants: g = 9.81, L = 1.0
var pendulum = Fn.new { |t, y|
  var theta = y[0]
  var omega = y[1]
  
  var dTheta = omega
  var dOmega = -9.81 / 1.0 * theta.sin // Small angle approximation or full sin
  
  return [dTheta, dOmega]
}

var solver = SystemSolver.new(pendulum)
// Start at 0.5 radians (approx 28 degrees), 0 velocity
solver.solve([0.5, 0.0], 0, 2, 20)
