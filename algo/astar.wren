import "os" for Process
import "timer" for Timer

class AStarSearch {
  construct new(width, height) {
    _w = width
    _h = height
    _grid = List.filled(_h, null)
    for (i in 0..._h) _grid[i] = List.filled(_w, " ")
    
    _start = [0, 0]
    _end = [_w - 1, _h - 1]
    
    // Simple static wall for demonstration
    for (i in 0...12) _grid[i][10] = "#"
  }

  // Manhattan Distance Heuristic: |x1 - x2| + |y1 - y2|
  heuristic(x, y) {
    return (x - _end[0]).abs + (y - _end[1]).abs
  }

  draw(visited) {
    System.write("\e[H")
    System.print("--- Search Visualizer: A* (Heuristic Search) ---")
    for (y in 0..._h) {
      var line = ""
      for (x in 0..._w) {
        var key = "%(x),%(y)"
        if (x == _start[0] && y == _start[1]) {
            line = line + "\e[32mS \e[0m"
        } else if (x == _end[0] && y == _end[1]) {
            line = line + "\e[31mE \e[0m"
        } else if (_grid[y][x] == "#") {
            line = line + "█ "
        } else if (visited.containsKey(key)) {
            line = line + "\e[33m* \e[0m" // Yellow for A*
        } else {
            line = line + ". "
        }
      }
      System.print(line)
    }
    Timer.sleep(50)
  }

  run() {
    // openSet stores: [x, y, gScore, fScore]
    var openSet = [[_start[0], _start[1], 0, heuristic(_start[0], _start[1])]]
    var visited = {}

    while (openSet.count > 0) {
      // 1. Sort by fScore (the lowest total cost) to act as Priority Queue
      openSet.sort { |a, b| a[3] < b[3] }
      var curr = openSet.removeAt(0)
      
      var x = curr[0]
      var y = curr[1]
      var g = curr[2]
      var key = "%(x),%(y)"

      if (x == _end[0] && y == _end[1]) return true
      if (visited.containsKey(key)) continue
      
      visited[key] = true
      draw(visited)

      // 2. Check neighbors
      for (dir in [[0, 1], [1, 0], [0, -1], [-1, 0]]) {
        var nx = x + dir[0]
        var ny = y + dir[1]
        var nKey = "%(nx),%(ny)"

        if (nx >= 0 && nx < _w && ny >= 0 && ny < _h && _grid[ny][nx] != "#" && !visited.containsKey(nKey)) {
          var nextG = g + 1
          var nextF = nextG + heuristic(nx, ny)
          openSet.add([nx, ny, nextG, nextF])
        }
      }
    }
    return false
  }
}

// --- Main ---
System.print("\e[2J")
var astar = AStarSearch.new(20, 15)
astar.run()
System.print("\nTarget Found using A*!")
