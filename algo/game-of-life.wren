import "random" for Random

class GameOfLife {
  construct new(width, height) {
    _w = width
    _h = height
    _grid = List.filled(_w * _h, false)
    _nextGrid = List.filled(_w * _h, false)
    _rng = Random.new()
  }

  at(x, y) {
    x = x % _w
    y = y % _h
    if (x < 0) x = x + _w
    if (y < 0) y = y + _h
    return _grid[y * _w + x]
  }

  seed(probability) {
    for (i in 0...(_w * _h)) {
      _grid[i] = _rng.float() < probability
    }
  }

  update() {
    for (y in 0..._h) {
      for (x in 0..._w) {
        var count = 0
        // Inline neighbor check for speed and simplicity
        for (dy in -1..1) {
          for (dx in -1..1) {
            if (!(dx == 0 && dy == 0) && at(x + dx, y + dy)) count = count + 1
          }
        }

        var alive = at(x, y)
        if (alive) {
          _nextGrid[y * _w + x] = (count == 2 || count == 3)
        } else {
          _nextGrid[y * _w + x] = (count == 3)
        }
      }
    }
    // Swap state
    for (i in 0...(_w * _h)) _grid[i] = _nextGrid[i]
  }

  render() {
    // Clear screen and reset cursor
    System.write("\u001b[2J\u001b[H") 
    for (y in 0..._h) {
      var row = ""
      for (x in 0..._w) {
        row = row + (at(x, y) ? "O " : ". ")
      }
      System.print(row)
    }
  }
}

// Execution
var game = GameOfLife.new(20, 10)
game.seed(0.3)

for (gen in 1..50) {
  game.render()
  System.print("Generation: %(gen)")
  game.update()
  
  // Minimal delay loop
  var start = System.clock
  while (System.clock - start < 0.1) {}
}
