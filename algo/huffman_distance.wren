class HuffmanNode {
  construct new(char, freq) {
    _char = char
    _freq = freq
    _left = null
    _right = null
  }
  char { _char }
  freq { _freq }
  left { _left }
  left=(v) { _left = v }
  right { _right }
  right=(v) { _right = v }
}

class Huffman {
  static compress(text) {
    if (text.count == 0) return ""

    // 1. Count frequencies
    var freqs = {}
    for (char in text) {
      freqs[char] = (freqs[char] || 0) + 1
    }

    // 2. Create nodes and sort (Priority Queue)
    var nodes = []
    for (char in freqs.keys) {
      nodes.add(HuffmanNode.new(char, freqs[char]))
    }

    // 3. Build the Tree
    while (nodes.count > 1) {
      // Sort by frequency
      nodes.sort { |a, b| a.freq < b.freq }
      
      // Take the two smallest
      var left = nodes.removeAt(0)
      var right = nodes.removeAt(0)
      
      // Merge them into a new parent node
      var parent = HuffmanNode.new(null, left.freq + right.freq)
      parent.left = left
      parent.right = right
      nodes.add(parent)
    }

    var root = nodes[0]
    var codes = {}
    generateCodes(root, "", codes)

    // 4. Encode the text
    var result = ""
    for (char in text) {
      result = result + codes[char]
    }
    
    return { "encoded": result, "codes": codes }
  }

  static generateCodes(node, currentCode, codes) {
    if (!node) return
    
    // If it's a leaf node, it has a character
    if (node.char != null) {
      codes[node.char] = currentCode
    }

    generateCodes(node.left, currentCode + "0", codes)
    generateCodes(node.right, currentCode + "1", codes)
  }
  
  static decompress(encoded, codes) {
    // We need to flip the table so we can look up bits -> character
    var reverseCodes = {}
    for (char in codes.keys) {
      reverseCodes[codes[char]] = char
    }

    var result = ""
    var buffer = ""

    for (bit in encoded) {
      buffer = buffer + bit // Keep adding bits until we find a match

      if (reverseCodes.containsKey(buffer)) {
        result = result + reverseCodes[buffer]
        buffer = "" // Reset the buffer once a character is found
      }
    }
    return result
  }
}

// --- Test ---
var message = "BEEP BOOP BEER"
var result = Huffman.compress(message)

// 1. Compress
System.print("Original: " + message)
System.print("Encoded:  " + result["encoded"])
System.print("\nCode Table:")
for (key in result["codes"].keys) {
  System.print("'%(key)': %(result["codes"][key])")
}

// 2. Decompress
var decoded = Huffman.decompress(result["encoded"], result["codes"])
System.print("Recovered: " + decoded)

if (message == decoded) {
  System.print("\nSuccess! Data recovered perfectly.")
}
