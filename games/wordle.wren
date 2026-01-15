import "random" for Random
import "io" for Stdin

var ToUpper = Fn.new { |str| 
  var out = ""
  for (c in str.bytes) {
    if (c >= 97 && c <= 122) {
      out = out + String.fromByte(c - 32)
    } else {
      out = out + String.fromByte(c)
    }
  }
  return out
}


class Wordle {
  construct new() {
    _words = ["APPLE", "BEACH", "BRAIN", "CLOUD", "DRINK", "FLAME", "GRAPE", "HOUSE", "LIGHT", "PLANT", "SMILE", "TRAIN", "WATER", "YOUTH"]
    _rng = Random.new()
    _maxAttempts = 6
    reset()
  }

  reset() {
    _target = _words[_rng.int(_words.count)]
    _attempts = []
    _gameOver = false
  }

  // ANSI Color codes
  static GREEN { "\e[42m\e[30m" }
  static YELLOW { "\e[43m\e[30m" }
  static GRAY { "\e[100m\e[37m" }
  static RESET { "\e[0m" }

  play() {
    System.print("--- WREN-WORDLE ---")
    System.print("Guess the 5-letter word!")

    while (_attempts.count < _maxAttempts && !_gameOver) {
      displayBoard()
      System.write("Guess %(_attempts.count + 1)/%(_maxAttempts): ")
      var guess = ToUpper.call(Stdin.readLine())

      if (guess.count != 5) {
        System.print("! Must be 5 letters.")
        continue
      }

      _attempts.add(processGuess(guess))

      if (guess == _target) {
        _gameOver = true
        displayBoard()
        System.print("\n✨ Splendid! You got it in %(_attempts.count) tries.")
      }
    }

    if (!_gameOver && _attempts.count == _maxAttempts) {
      displayBoard()
      System.print("\nBetter luck next time! The word was: %(_target)")
    }
  }

  processGuess(guess) {
    var result = List.filled(5, "")
    var targetUsed = List.filled(5, false)
    var guessProcessed = List.filled(5, false)

    // 1. First pass: Find Greens (Correct spot)
    for (i in 0...5) {
      if (guess[i] == _target[i]) {
        result[i] = Wordle.GREEN + " " + guess[i] + " " + Wordle.RESET
        targetUsed[i] = true
        guessProcessed[i] = true
      }
    }

    // 2. Second pass: Find Yellows (Wrong spot)
    for (i in 0...5) {
      if (guessProcessed[i]) continue

      var found = false
      for (j in 0...5) {
        if (!targetUsed[j] && guess[i] == _target[j]) {
          result[i] = Wordle.YELLOW + " " + guess[i] + " " + Wordle.RESET
          targetUsed[j] = true
          found = true
          break
        }
      }

      if (!found) {
        result[i] = Wordle.GRAY + " " + guess[i] + " " + Wordle.RESET
      }
    }

    return result.join(" ")
  }

  displayBoard() {
    System.write("\e[2J\e[H") // Clear screen
    System.print("WREN-WORDLE\n")
    
    for (attempt in _attempts) {
      System.print(attempt)
    }

    // Print empty slots
    var remaining = _maxAttempts - _attempts.count
    if (remaining > 0) {
      for (i in 0...remaining) {
        System.print("⬜ ⬜ ⬜ ⬜ ⬜")
      }
    }
    System.print("")
  }
}

var game = Wordle.new()
game.play()
