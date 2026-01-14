class Sudoku {
  construct new(board) {
    _grid = board
  }

  // ANSI Colors for better visibility
  static BLUE { "\u001b[34m" }
  static GREEN { "\u001b[32m" }
  static RESET { "\u001b[0m" }

  // Check if placing 'num' at grid[row][col] is valid
  isValid(row, col, num) {
    for (i in 0...9) {
      // Check row and column
      if (_grid[row][i] == num || _grid[i][col] == num) return false
    }

    // Check 3x3 sub-box
    var startRow = (row / 3).floor * 3
    var startCol = (col / 3).floor * 3
    for (r in startRow...startRow + 3) {
      for (c in startCol...startCol + 3) {
        if (_grid[r][c] == num) return false
      }
    }
    return true
  }

  // Recursive solver
  solve() {
    for (row in 0...9) {
      for (col in 0...9) {
        if (_grid[row][col] == 0) {
          for (num in 1..9) {
            if (isValid(row, col, num)) {
              _grid[row][col] = num
              
              if (solve()) return true // Found a path to the end
              
              _grid[row][col] = 0 // Backtrack
            }
          }
          return false // No number works here
        }
      }
    }
    return true // No empty cells left
  }

  printGrid() {
    for (r in 0...9) {
      if (r % 3 == 0 && r != 0) System.print("------+-------+------")
      var line = ""
      for (c in 0...9) {
        if (c % 3 == 0 && c != 0) line = line + "| "
        var val = _grid[r][c]
        line = line + (val == 0 ? ". " : Sudoku.GREEN + val.toString + " " + Sudoku.RESET)
      }
      System.print(line)
    }
  }
}

// 0 represents empty cells
var board = [
  [0, 3, 0, 0, 7, 0, 0, 0, 0],
  [6, 0, 0, 1, 9, 5, 0, 0, 0],
  [0, 9, 8, 0, 0, 0, 0, 6, 0],
  [8, 0, 0, 0, 6, 0, 0, 0, 3],
  [4, 0, 0, 8, 0, 3, 0, 0, 1],
  [7, 0, 0, 0, 2, 0, 0, 0, 6],
  [0, 6, 0, 0, 0, 0, 2, 8, 0],
  [0, 0, 0, 4, 1, 9, 0, 0, 5],
  [0, 0, 0, 0, 8, 0, 0, 7, 9]
]

var game = Sudoku.new(board)

System.print("Puzzle to Solve:")
game.printGrid()

if (game.solve()) {
  System.print("\nSolved Successfully:")
  game.printGrid()
} else {
  System.print("\nNo solution exists.")
}
