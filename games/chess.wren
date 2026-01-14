import "io" for Stdin

class Chess {
  construct new() {
    _board = List.filled(64, "")
    _whiteTurn = true
    _status = "White to move (e.g., 'e2e4')"
    setup()
  }

  setup() {
    var layout = ["R", "N", "B", "Q", "K", "B", "N", "R"]
    for (i in 0..7) {
      // FIX: Convert the byte calculation back into a String
      var blackPieceByte = layout[i].bytes[0] + 32
      _board[i] = String.fromByte(blackPieceByte) // Black (lowercase)
      
      _board[i + 8] = "p"
      _board[i + 48] = "P"
      _board[i + 56] = layout[i] // White (uppercase)
    }
  }

  algebraicToIndex(coord) {
    if (coord.count < 2) return -1
    // Convert 'a'-'h' to 0-7
    var file = coord[0].bytes[0] - 97 
    // Convert '1'-'8' to 7-0
    var rank = 8 - (coord[1].bytes[0] - 48) 
    
    if (file < 0 || file > 7 || rank < 0 || rank > 7) return -1
    return rank * 8 + file
  }

  move(input) {
    if (input.count < 4) {
      _status = "Invalid format. Use 'e2e4'."
      return
    }

    var from = algebraicToIndex(input[0..1])
    var to = algebraicToIndex(input[2..3])

    if (from == -1 || to == -1 || _board[from] == "") {
      _status = "Invalid move or empty square."
      return
    }

    var piece = _board[from]
    var isWhite = piece.bytes[0] < 97
    if (isWhite != _whiteTurn) {
      _status = "It is %(_whiteTurn ? "White" : "Black")'s turn!"
      return
    }

    // Basic capture check (cannot take your own piece)
    var target = _board[to]
    if (target != "" && (target.bytes[0] < 97) == isWhite) {
      _status = "Cannot capture your own piece."
      return
    }

    _board[to] = piece
    _board[from] = ""
    _whiteTurn = !_whiteTurn
    _status = "Moved %(input). %(_whiteTurn ? "White" : "Black") to move."
  }

  getIcon(p) {
    if (p == "" || p == null) return "."
    var icons = {
      "K": "♔", "Q": "♕", "R": "♖", "B": "♗", "N": "♘", "P": "♙",
      "k": "♚", "q": "♛", "r": "♜", "b": "♝", "n": "♞", "p": "♟"
    }
    return icons[p]
  }

  render() {
    System.write("\u001b[2J\u001b[H") // Clear screen
    System.print("    a  b  c  d  e  f  g  h")
    System.print("  +------------------------+")
    for (y in 0..7) {
      var row = "%(8 - y) |" 
      for (x in 0..7) {
        var p = _board[y * 8 + x]
        var icon = getIcon(p)
        row = row + " %(icon) "
      }
      System.print("%(row)| %(8 - y)")
    }
    System.print("  +------------------------+")
    System.print("    a  b  c  d  e  f  g  h")
    System.print("\n%(_status)")
  }
}

// --- Main Loop ---
var game = Chess.new()

while (true) {
  game.render()
  System.write("\n> ")
  
  // Using the Stdin class from the 'io' module
  var input = Stdin.readLine()
  
  if (input == null || input == "quit") break
  if (input.count >= 4) {
    game.move(input)
  }
}
