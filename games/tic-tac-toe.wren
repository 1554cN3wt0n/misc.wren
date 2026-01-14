import "io" for Stdin

class TicTacToe {
  construct new() {
    // Board indices: 0-8
    _board = List.filled(9, " ")
    _player = "X" // Human
    _ai = "O"     // Computer
  }

  // Check if a player has won
  checkWin(b, p) {
    var winStates = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Cols
      [0, 4, 8], [2, 4, 6]             // Diagonals
    ]
    for (combo in winStates) {
      if (b[combo[0]] == p && b[combo[1]] == p && b[combo[2]] == p) return true
    }
    return false
  }

  getEmptyIndices(b) {
    var indices = []
    for (i in 0..8) {
      if (b[i] == " ") indices.add(i)
    }
    return indices
  }

  // The Minimax Algorithm
  minimax(board, depth, isMaximizing) {
    if (checkWin(board, _ai)) return 10 - depth
    if (checkWin(board, _player)) return depth - 10
    if (getEmptyIndices(board).count == 0) return 0

    if (isMaximizing) {
      var bestScore = -999
      for (idx in getEmptyIndices(board)) {
        board[idx] = _ai
        var score = minimax(board, depth + 1, false)
        board[idx] = " "
        if (score > bestScore) bestScore = score
      }
      return bestScore
    } else {
      var bestScore = 999
      for (idx in getEmptyIndices(board)) {
        board[idx] = _player
        var score = minimax(board, depth + 1, true)
        board[idx] = " "
        if (score < bestScore) bestScore = score
      }
      return bestScore
    }
  }

  findBestMove() {
    var bestScore = -999
    var move = -1
    for (idx in getEmptyIndices(_board)) {
      _board[idx] = _ai
      var score = minimax(_board, 0, false)
      _board[idx] = " "
      if (score > bestScore) {
        bestScore = score
        move = idx
      }
    }
    return move
  }

  render() {
    System.write("\u001b[2J\u001b[H") // Clear
    System.print(" TIC-TAC-TOE (AI)")
    System.print(" %(_board[0]) | %(_board[1]) | %(_board[2])")
    System.print("-----------")
    System.print(" %(_board[3]) | %(_board[4]) | %(_board[5])")
    System.print("-----------")
    System.print(" %(_board[6]) | %(_board[7]) | %(_board[8])\n")
  }

  play() {
    while (true) {
      render()
      
      // Human Turn
      System.write("Choose square (1-9): ")
      var input = Stdin.readLine()
      var choice = Num.fromString(input)
      if (choice == null || choice < 1 || choice > 9 || _board[choice - 1] != " ") {
        System.print("Invalid move!")
        continue
      }
      _board[choice - 1] = _player
      
      if (checkWin(_board, _player)) {
        render()
        System.print("You won! (Wait, how?)")
        break
      }

      if (getEmptyIndices(_board).count == 0) {
        render()
        System.print("It's a draw!")
        break
      }

      // AI Turn
      var aiMove = findBestMove()
      _board[aiMove] = _ai

      if (checkWin(_board, _ai)) {
        render()
        System.print("AI wins! Resistance is futile.")
        break
      }
    }
  }
}

var game = TicTacToe.new()
game.play()
