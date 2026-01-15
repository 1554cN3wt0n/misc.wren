import "os" for Process
import "timer" for Timer

class GridSearch {
  construct new(width, height) {
    _w = width
    _h = height
    _grid = List.filled(_h, null)
    for (i in 0..._h) _grid[i] = List.filled(_w, " ")
    
    _start = [0, 0]
    _end = [_w - 1, _h - 1]
    
    // Add some random walls (#)
    for (i in 0...(_w * _h / 4).floor) {
      var rx = (System.clock * 12345 % _w).floor
      var ry = (System.clock * 54321 % _h).floor
      if ((rx != 0 || ry != 0) && (rx != _w-1 || ry != _h-1)) {
        _grid[ry][rx] = "#"
      }
    }
  }

  draw(visited) {
    System.write("\e[H") // Reset cursor
    System.print("--- Search Visualizer: DFS vs BFS ---")
    for (y in 0..._h) {
      var line = ""
      for (x in 0..._w) {
        if (x == _start[0] && y == _start[1]) {
          line = line + "\e[32mS \e[0m" // Green Start
        } else if (x == _end[0] && y == _end[1]) {
          line = line + "\e[31mE \e[0m" // Red End
        } else if (_grid[y][x] == "#") {
          line = line + "█ "          // Wall
        } else if (visited.containsKey("%(x),%(y)")) {
          line = line + "\e[36m· \e[0m" // Cyan Visited
        } else {
          line = line + "  "
        }
      }
      System.print(line)
    }
    Timer.sleep(30)
  }

  // BFS uses a QUEUE (First-In, First-Out)
  bfs() {
    var queue = [_start]
    var visited = {}
    visited["0,0"] = true

    while (queue.count > 0) {
      var curr = queue.removeAt(0)
      if (curr[0] == _end[0] && curr[1] == _end[1]) return true

      for (dir in [[0, 1], [1, 0], [0, -1], [-1, 0]]) {
        var nx = curr[0] + dir[0]
        var ny = curr[1] + dir[1]
        var key = "%(nx),%(ny)"

        if (nx >= 0 && nx < _w && ny >= 0 && ny < _h && 
            _grid[ny][nx] != "#" && !visited.containsKey(key)) {
          visited[key] = true
          queue.add([nx, ny])
          draw(visited)
        }
      }
    }
    return false
  }

  // DFS uses a STACK (Last-In, First-Out)
  dfs() {
    var stack = [_start]
    var visited = {}

    while (stack.count > 0) {
      var curr = stack.removeAt(-1)
      var key = "%(curr[0]),%(curr[1])"
      
      if (visited.containsKey(key)) continue
      visited[key] = true
      draw(visited)

      if (curr[0] == _end[0] && curr[1] == _end[1]) return true

      for (dir in [[0, 1], [1, 0], [0, -1], [-1, 0]]) {
        var nx = curr[0] + dir[0]
        var ny = curr[1] + dir[1]
        if (nx >= 0 && nx < _w && ny >= 0 && ny < _h && _grid[ny][nx] != "#") {
          stack.add([nx, ny])
        }
      }
    }
    return false
  }
}

// --- Main ---
var args = Process.arguments
if (args.count < 1) {
  System.print("Usage: wren script.wren [bfs|dfs]")
} else {
System.print("\e[2J") // Clear
  var searcher = GridSearch.new(20, 15)
  if (args[0] == "bfs") {
      searcher.bfs()
  } else if (args[0] == "dfs") {
      searcher.dfs()
  } else {
      System.print("\noption not supported")
  }
  System.print("\nSearch Finished!")
}
