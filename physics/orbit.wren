var PadLeft = Fn.new {|str, l|
    if (l <= str.count) return str
    return str + " " * (l - str.count)
}

class Vector {
  construct new(x, y) {
    _x = x
    _y = y
  }
  x { _x }
  y { _y }
  
  +(o) { Vector.new(_x + o.x, _y + o.y) }
  -(o) { Vector.new(_x - o.x, _y - o.y) }
  *(s) { Vector.new(_x * s, _y * s) }
  
  magSq { _x*_x + _y*_y }
  mag   { magSq.sqrt }
  
  // Normalized vector (direction only)
  unit {
    var m = mag
    return (m == 0) ? Vector.new(0, 0) : this * (1/m)
  }
}

class OrbitSim {
  construct new() {
    // Initial State: Earth-like orbit
    _pos = Vector.new(150, 0)   // 150 units from the sun
    _vel = Vector.new(0, 5)     // Tangential velocity
    _sunPos = Vector.new(0, 0)
    _mu = 4000                  // Standard gravitational parameter (G * M)
    _dt = 0.1                   // Time step
  }

  // Calculate acceleration: a = GM / r^2 in the direction of the sun
  getAcc(p) {
    var diff = _sunPos - p
    var distSq = diff.magSq
    var direction = diff.unit
    return direction * (_mu / distSq)
  }

  step() {
    // Velocity Verlet Integration
    var acc = getAcc(_pos)
    
    // 1. Update position: p = p + v*dt + 0.5*a*dt^2
    _pos = _pos + (_vel * _dt) + (acc * (0.5 * _dt * _dt))
    
    // 2. Get new acceleration at the new position
    var newAcc = getAcc(_pos)
    
    // 3. Update velocity: v = v + 0.5*(a + new_a)*dt
    _vel = _vel + ((acc + newAcc) * (0.5 * _dt))
  }

  run(iterations) {
    System.print("Time | Pos X  | Pos Y")
    System.print("---------------------")
    for (t in 0...iterations) {
      step()
      if (t % 10 == 0) { // Print every 10th step to keep it readable
        System.print("%(PadLeft.call(t.toString,4)) | %(PadLeft.call(_pos.x.toString,6)) | %(PadLeft.call(_pos.y.toString,6))")
      }
    }
  }
}

var sim = OrbitSim.new()
sim.run(200)
