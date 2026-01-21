var PadEnd = Fn.new { |str, size|
    if (str.count >= size) return str
    return str + " " * (size - str.count)
}

class ODESolver {
  // We use a closure (function) for the differential equation f(t, y)
  construct new(df) {
    _df = df
  }

  // Performs a single RK4 step
  // t: current time, y: current value, h: step size
  step(t, y, h) {
    var k1 = _df.call(t, y)
    var k2 = _df.call(t + h/2, y + h*k1/2)
    var k3 = _df.call(t + h/2, y + h*k2/2)
    var k4 = _df.call(t + h, y + h*k3)

    return y + (h/6) * (k1 + 2*k2 + 2*k3 + k4)
  }

  // Solves over an interval
  solve(y0, tStart, tEnd, steps) {
    var h = (tEnd - tStart) / steps
    var t = tStart
    var y = y0

    System.print("Time: %(PadEnd.call(t.toString,8)) | Value: %(y)")
    
    for (i in 1..steps) {
      y = step(t, y, h)
      t = t + h
      System.print("Time: %(PadEnd.call(t.toString,8)) | Value: %(y)")
    }
    return y
  }
}

// --- Example Usage ---
// Let's solve dy/dt = y - t^2 + 1
// Initial condition: y(0) = 0.5
// Exact solution is y(t) = (t + 1)^2 - 0.5e^t

var myDf = Fn.new { |t, y| y - t*t + 1 }
var solver = ODESolver.new(myDf)

System.print("Solving dy/dt = y - t^2 + 1...")
solver.solve(0.5, 0, 2, 10)
