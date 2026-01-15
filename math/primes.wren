import "../common/bigint" for BigInt

class PrimeGenerator {
  // Returns a list of primes up to 'limit'
  static sequence(limit) {
    var primes = []
    var current = BigInt.new("2")
    var max = BigInt.new(limit.toString)

    while (current.compare(max) <= 0) {
      if (this.isPrime(current)) {
        primes.add(current.toString)
      }
      current = current + BigInt.new("1")
    }
    return primes
  }

  // Optimized Trial Division for BigInt
  static isPrime(n) {
    var nNum = Num.fromString(n.toString)
    if (nNum < 2) return false
    if (nNum == 2 || nNum == 3) return true
    if (nNum % 2 == 0 || nNum % 3 == 0) return false

    // We only need to check up to sqrt(n)
    var limit = nNum.sqrt.floor
    var i = 5
    while (i <= limit) {
      if (nNum % i == 0 || nNum % (i + 2) == 0) return false
      i = i + 6
    }
    return true
  }
}

// --- Execution ---
var limit = 100
System.print("Calculating primes up to %(limit):")
var result = PrimeGenerator.sequence(limit)
System.print(result.join(", "))
