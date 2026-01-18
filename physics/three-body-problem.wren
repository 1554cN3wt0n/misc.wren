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

class Body {
  construct new(name, mass, pos, vel) {
    _name = name
    _mass = mass
    _pos = pos
    _vel = vel
  }
  name { _name }
  mass { _mass }
  pos { _pos }
  pos=(v) { _pos = v }
  vel { _vel }
  vel=(v) { _vel = v }
}

class ThreeBodySim {
  construct new() {
    _G = 100 // Gravitational constant for our universe
    _dt = 0.05
    
    // Setup: A heavy sun and two planets
    _bodies = [
      Body.new("Sun",     500, Vector.new(0, 0),    Vector.new(0, 0)),
      Body.new("PlanetA", 1,   Vector.new(100, 0),  Vector.new(0, 20)),
      Body.new("PlanetB", 1,   Vector.new(0, 150),  Vector.new(-15, 0))
    ]
  }

  // Calculate the total acceleration on body 'i' from all other bodies
  computeAcc(i, bodies) {
    var acc = Vector.new(0, 0)
    var b1 = bodies[i]
    
    for (j in 0...bodies.count) {
      if (i == j) continue
      var b2 = bodies[j]
      
      var r = b2.pos - b1.pos
      var distSq = r.magSq
      var dist = distSq.sqrt
      
      if (dist < 1) continue // Prevent division by zero/extreme slingshots
      
      // Newton's Law: a = G * m2 / r^2
      var forceMag = _G * b2.mass / distSq
      acc = acc + (r.unit * forceMag)
    }
    return acc
  }

  step() {
    // 1. Pre-calculate accelerations for all bodies
    var accelerations = []
    for (i in 0..._bodies.count) {
      accelerations.add(computeAcc(i, _bodies))
    }

    // 2. Update positions and velocities (Semi-implicit Euler for simplicity)
    for (i in 0..._bodies.count) {
      var b = _bodies[i]
      var a = accelerations[i]
      
      b.vel = b.vel + (a * _dt)
      b.pos = b.pos + (b.vel * _dt)
    }
  }

  run(steps) {
    for (s in 0...steps) {
      step()
      if (s % 50 == 0) {
        System.print("Step %(s):")
        for (b in _bodies) {
          System.print("  %(b.name) | x: %(b.pos.x.toString) y: %(b.pos.y.toString)")
        }
      }
    }
  }
}

var sim = ThreeBodySim.new()
sim.run(500)
