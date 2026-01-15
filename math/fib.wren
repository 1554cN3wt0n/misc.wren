import "../common/bigint" for BigInt

class Fibonacci {
  static generate(n) {
    if (n == 0) return [BigInt.new("0")]
    if (n == 1) return [BigInt.new("0"), BigInt.new("1")]

    var sequence = [BigInt.new("0"), BigInt.new("1")]
    
    // We keep track of the last two numbers to find the next
    var a = BigInt.new("0")
    var b = BigInt.new("1")

    for (i in 2..n) {
      var next = a + b
      sequence.add(next)
      
      // Shift our pointers forward
      a = b
      b = next
    }
    
    return sequence
  }

  // A more memory-efficient version that only returns the Nth number
  static nth(n) {
    var a = BigInt.new("0")
    var b = BigInt.new("1")
    if (n == 0) return a
    if (n == 1) return b

    for (i in 2..n) {
      var temp = a + b
      a = b
      b = temp
    }
    return b
  }
}

// --- Execution ---
var count = 100
System.print("The first %(count) Fibonacci numbers:")
var fibs = Fibonacci.generate(count)

for (i in 2...fibs.count) {
  System.print("%(i): " + fibs[i].toString + " ,Golden ratio (phi): " + BigInt.trueDiv(fibs[i-1], fibs[i], 20).toString)
}

System.print("\nVerification (100th Fibonacci):")
System.print(Fibonacci.nth(100).toString)
