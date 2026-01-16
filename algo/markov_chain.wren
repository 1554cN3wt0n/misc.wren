import "random" for Random

class MarkovChain {
  construct new() {
    _map = {}
    _rng = Random.new()
    _words = []
  }

  // 1. Train the model with text
  train(text) {
    _words = text.split(" ").where { |w| w != "" }.toList
    if (_words.count < 3) return

    for (i in 0..._words.count - 2) {
      var key = _words[i] + " " + _words[i+1]
      var nextWord = _words[i+2]

      if (!_map.containsKey(key)) _map[key] = []
      _map[key].add(nextWord)
    }
  }

  // 2. Generate new text
  generate(length) {
    if (_map.isEmpty) return ""

    // Pick a random starting point
    var keys = _map.keys.toList
    var currentKey = keys[_rng.int(keys.count)]
    var output = currentKey.split(" ")

    for (i in 0...length) {
      var candidates = _map[currentKey]
      if (!candidates || candidates.isEmpty) break

      // Pick a random word from the candidates
      var nextWord = candidates[_rng.int(candidates.count)]
      output.add(nextWord)

      // Update the key to the last two words
      currentKey = output[output.count - 2] + " " + output[output.count - 1]
    }

    return output.join(" ")
  }
}

// --- Test Case ---
var corpus = "it was the best of times it was the worst of times " +
             "it was the age of wisdom it was the age of foolishness"

var mc = MarkovChain.new()
mc.train(corpus)

System.print("Generated Text:")
System.print(mc.generate(10))
