import "../common/complex" for Complex

class PolySolver {
  // Coefficients: [a_n, ..., a_1, a_0] for a_n*x^n + ... + a_0 = 0
  static solve(coeffs) {
    var n = coeffs.count - 1
    if (n < 1) return []

    // 1. Normalize (lead coefficient must be 1)
    var lead = coeffs[0]
    var a = coeffs.map { |c| c / lead }.toList

    // 2. Initialize guesses (using a complex offset to avoid symmetry)
    var roots = []
    for (i in 0...n) {
      var angle = (2 * 3.14159 * i) / n
      roots.add(Complex.new(angle.cos, angle.sin))
    }

    // 3. Iteratively refine roots
    for (iter in 0..100) {
      var nextRoots = []
      for (i in 0...n) {
        var p_ri = this.evaluate(a, roots[i])
        var denominator = Complex.new(1, 0)
        
        for (j in 0...n) {
          if (i != j) denominator = denominator * (roots[i] - roots[j])
        }
        
        nextRoots.add(roots[i] - (p_ri / denominator))
      }
      roots = nextRoots
    }
    return roots
  }

  static evaluate(coeffs, x) {
    var val = Complex.new(0, 0)
    var n = coeffs.count - 1
    for (i in 0..n) {
      var term = Complex.new(coeffs[i], 0)
      // Power: x^(n-i)
      var p = Complex.new(1, 0)
      for (j in 0...(n - i)) p = p * x
      val = val + (term * p)
    }
    return val
  }
}

// --- Test: x^2 - 5x + 6 = 0 (Roots should be 2 and 3) ---
var coeffs = [1, -5, 6]
var roots = PolySolver.solve(coeffs)

System.print("Solving x^2 - 5x + 6 = 0")
for (r in roots) System.print("Root: %(r)")

// --- Test: x^2 + 1 = 0 (Roots should be i and -i) ---
var roots2 = PolySolver.solve([1, 0, 1])
System.print("\nSolving x^2 + 1 = 0")
for (r in roots2) System.print("Root: %(r)")

// --- Test: x^3 + x^2 + x + 2 = 0 ---
var roots3 = PolySolver.solve([1, 1, 1, 2])
System.print("\nSolving x^3 + x^2 + x + 2 = 0")
for (r in roots3) System.print("Root: %(r)")
