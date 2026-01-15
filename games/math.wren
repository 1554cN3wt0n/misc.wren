import "random" for Random
import "io" for Stdin, Stdout

var RNG = Random.new()

class MathGame {
  construct new() {
    _level = 1
    _questionsPerLevel = 16
    _ops = ["+", "-", "*"]
  }

  // Generates questions that scale in complexity
  generateQuestion(level) {
    var numCount = (level < 10) ? 2 : (level < 20 ? 3 : 4)
    var maxVal = (level < 15) ? 50 : 200
    
    var nums = []
    for (i in 0...numCount) nums.add(RNG.int(2, maxVal))
    
    var question = "%(nums[0])"
    var answer = nums[0]

    for (i in 1...numCount) {
      var op = (level < 5) ? "+" : _ops[RNG.int(_ops.count)]
      var nextNum = nums[i]
      
      // Keep multiplication manageable
      if (op == "*") nextNum = RNG.int(2, (level < 15) ? 10 : 15)

      if (op == "+") answer = answer + nextNum
      if (op == "-") answer = answer - nextNum
      if (op == "*") answer = answer * nextNum
      
      question = question + " %(op) %(nextNum)"
    }

    return {"text": question, "ans": answer}
  }

  // Time drops from 60s at Level 1 to 15s at Level 30
  getTimeLimit(level) {
    return (60 - (level - 1) * 1.55).max(15)
  }

  start() {
    System.print("\e[2J\e[H") // Clear terminal
    System.print("=== ARITHMETIC ASCENSION: 30 LEVELS ===")
    System.print("Goal: 16 questions per level. Don't run out of time!")
    System.print("Press Enter to begin...")
    Stdin.readLine()

    while (_level <= 30) {
      if (!playLevel(_level)) {
        System.print("\n💀 GAME OVER! You failed at Level %(_level).")
        break
      }
      _level = _level + 1
      if (_level <= 30) {
        System.print("\n🌟 LEVEL COMPLETE! Prepare for Level %(_level)...")
        // Short pause
        var wait = System.clock
        while (System.clock - wait < 2) {} 
      }
    }

    if (_level > 30) System.print("\n🏆 CONGRATULATIONS! You are a Math Master!")
  }

  playLevel(level) {
    var timeLimit = getTimeLimit(level)
    var startTime = System.clock
    var solved = 0

    while (solved < _questionsPerLevel) {
      var q = generateQuestion(level)
      var elapsed = System.clock - startTime
      var remaining = (timeLimit - elapsed).max(0)

      if (remaining <= 0) {
        System.print("\n⏰ TIME'S UP!")
        return false
      }

      System.print("\nLevel: %(level)/30 | Time Left: %(remaining.floor)s")
      System.print("[%(solved + 1)/16]  %(q["text"]) = ")
      
      var input = Stdin.readLine()
      var playerAns = Num.fromString(input)

      // Re-check clock immediately after input
      if (System.clock - startTime > timeLimit) {
        System.print("\n⏰ You answered, but the timer expired!")
        return false
      }

      if (playerAns == q["ans"]) {
        solved = solved + 1
        System.print("✅ Correct!")
      } else {
        System.print("❌ Wrong! The answer was %(q["ans"])")
        return false
      }
    }
    return true
  }
}

var game = MathGame.new()
game.start()
