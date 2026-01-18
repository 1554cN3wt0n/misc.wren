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

class Point {
  construct new(x, y) {
    _pos = Vector.new(x, y)
    _prevPos = Vector.new(x, y)
    _acc = Vector.new(0, 0)
    _pinned = false
  }

  pin() { _pinned = true }
  pos { _pos }
  pos=(v) { 
      if (!_pinned) {
        _pos = v
      }
  }

  update(dt) {
    if (_pinned) return
    
    // Verlet Integration: pos = pos + (pos - prevPos) + acc * dt * dt
    var velocity = _pos - _prevPos
    _prevPos = _pos
    _pos = _pos + velocity + (_acc * (dt * dt))
    
    // Reset acceleration for next frame
    _acc = Vector.new(0, 0)
  }

  applyForce(f) { _acc = _acc + f }
}

class Constraint {
  construct new(p1, p2, dist) {
    _p1 = p1
    _p2 = p2
    _targetDist = dist
  }

  solve() {
    var diff = _p1.pos - _p2.pos
    var currentDist = diff.mag
    if (currentDist == 0) return
    
    var pct = (_targetDist - currentDist) / currentDist / 2
    var offset = diff * pct
    
    _p1.pos = _p1.pos + offset
    _p2.pos = _p2.pos - offset
  }
}

class ClothSim {
  construct new(width, height, spacing) {
    _points = []
    _constraints = []
    _gravity = Vector.new(0, 9.8)
    _dt = 0.1
    
    // Create Grid
    for (y in 0...height) {
      for (x in 0...width) {
        var p = Point.new(x * spacing, y * spacing)
        if (y == 0) p.pin() // Pin the top row
        _points.add(p)
        
        // Connect to Left
        if (x > 0) {
          _constraints.add(Constraint.new(p, _points[_points.count - 2], spacing))
        }
        // Connect to Up
        if (y > 0) {
          _constraints.add(Constraint.new(p, _points[_points.count - width - 1], spacing))
        }
      }
    }
  }

  step() {
    for (p in _points) {
      p.applyForce(_gravity)
      p.update(_dt)
    }

    // Solve constraints multiple times for stiffness
    for (i in 0...5) {
      for (c in _constraints) c.solve()
    }
  }

  run(frames) {
    for (f in 0...frames) {
      step()
      if (f % 10 == 0) {
        var bottomPoint = _points[_points.count - 1]
        System.print("Frame %(f.toString) | Bottom Point Y: %(bottomPoint.pos.y.toString)")
      }
    }
  }
}

var sim = ClothSim.new(5, 5, 20)
sim.run(100)
