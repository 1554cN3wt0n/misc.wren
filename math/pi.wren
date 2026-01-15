class BigInt {
   construct new(value) {
    if (value is String) {
      _digits = []
      for (i in value.count-1..0) {
        _digits.add(Num.fromString(value[i]))
      }
    } else if (value is List) {
      _digits = value
    } else if (value is Num) {
      var valueString = value.floor.toString
      _digits = []
      for (i in valueString.count-1..0) {
        _digits.add(Num.fromString(valueString[i]))
      }

    }
  }

  digits { _digits }

  static powerOf10(n) {
    var d = [1]
    for (i in 0...n) d.insert(0, 0)
    return BigInt.new(d)
  }

  +(other) {
    var res = []
    var carry = 0
    var i = 0
    while (i < _digits.count || i < other.digits.count || carry > 0) {
      var sum = carry + (i < _digits.count ? _digits[i] : 0) + (i < other.digits.count ? other.digits[i] : 0)
      res.add(sum % 10)
      carry = (sum / 10).floor
      i = i + 1
    }
    return BigInt.new(res)
  }

  -(other) {
    var res = []
    var borrow = 0
    for (i in 0..._digits.count) {
      var sub = _digits[i] - borrow - (i < other.digits.count ? other.digits[i] : 0)
      if (sub < 0) {
        sub = sub + 10
        borrow = 1
      } else {
        borrow = 0
      }
      res.add(sub)
    }
    while (res.count > 1 && res[-1] == 0) res.removeAt(-1)
    return BigInt.new(res)
  }

  *(other) {
    var res = List.filled(_digits.count + other.digits.count, 0)
    for (i in 0..._digits.count) {
      var carry = 0
      for (j in 0...other.digits.count) {
        var mul = _digits[i] * other.digits[j] + res[i + j] + carry
        res[i + j] = mul % 10
        carry = (mul / 10).floor
      }
      res[i + other.digits.count] = carry
    }
    while (res.count > 1 && res[-1] == 0) res.removeAt(-1)
    return BigInt.new(res)
  }

  divMod(divisor) {
    var quotient = []
    var remainder = BigInt.new("0")
    for (i in _digits.count - 1..0) {
      if (remainder.toString == "0") {
        remainder = BigInt.new([_digits[i]])
      } else {
        remainder.digits.insert(0, _digits[i])
      }
      var count = 0
      while (remainder.compare(divisor) >= 0) {
        remainder = remainder - divisor
        count = count + 1
      }
      quotient.insert(0, count)
    }
    while (quotient.count > 1 && quotient[-1] == 0) quotient.removeAt(-1)
    return [BigInt.new(quotient), remainder]
  }

  /(other) { divMod(other)[0] }

  compare(other) {
    if (_digits.count != other.digits.count) return _digits.count > other.digits.count ? 1 : -1
    for (i in _digits.count - 1..0) {
      if (_digits[i] > other.digits[i]) return 1
      if (_digits[i] < other.digits[i]) return -1
    }
    return 0
  }

  toString {
    var s = ""
    for (i in _digits.count-1..0) s = s + _digits[i].toString
    return s == "" ? "0" : s
  }
}

class PiChudnovsky {
  // Now takes both desired digits and number of iterations (k)
  static calculate(digits, kTerms) {
    var extra = 5
    var precision = digits + extra
    var scale = BigInt.powerOf10(precision)

    var C = BigInt.new("640320")
    var C3_24 = (C * C * C) / BigInt.new("24")

    // We pass kTerms as the upper bound for our Binary Splitting
    var result = this.bs(0, kTerms, C3_24)
    var P = result[0]
    var Q = result[1]
    var T = result[2]

    // Pi = (Constant * sqrt(10005) * Q) / T
    var constant = BigInt.new("426880")
    var s10005 = this.sqrt(10005, precision)

    var numerator = constant * s10005 * Q
    var finalInt = numerator / T

    var s = finalInt.toString
    if (s.count <= extra) return "0.000..." // Handle edge cases

    s = s[0...-extra] // Remove guard digits
    return s[0] + "." + s[1..-1]
  }

  static bs(a, b, C3_24) {
    if (b - a == 1) {
      var P
      var Q
      var T
      if (a == 0) {
        P = BigInt.new("1")
        Q = BigInt.new("1")
      } else {
        var aBI = BigInt.new(a)
        // P = (6a-5)(2a-1)(6a-1)
        P = (BigInt.new(6)*aBI - BigInt.new(5)) * (BigInt.new(2)*aBI - BigInt.new(1)) * (BigInt.new(6)*aBI - BigInt.new(1))
        Q = BigInt.new(a*a*a) * C3_24
      }

      // T = P * (13591409 + 545140134 * a)
      var term = BigInt.new("13591409") + (BigInt.new("545140134") * BigInt.new(a))
      T = P * term

      // Handle the alternating sign (-1)^k
      // Since our BigInt is unsigned, we'll return a 'isNegative' flag
      // or handle it in the merge step. For simplicity at 50 digits:
      var isNeg = (a % 2 == 1)
      return [P, Q, T, isNeg]
    }

    var m = ((a + b) / 2).floor
    var left = bs(a, m, C3_24)
    var right = bs(m, b, C3_24)

    var newP = left[0] * right[0]
    var newQ = left[1] * right[1]

    // Merge T with sign logic: T = T_l*Q_r + P_l*T_r
    // If signs differ, we subtract the smaller from the larger
    var term1 = left[2] * right[1]
    var term2 = left[0] * right[2]
    var newT
    var newNeg

    if (left[3] == right[3]) { // Both same sign
      newT = term1 + term2
      newNeg = left[3]
    } else { // Different signs
      if (term1.compare(term2) >= 0) {
        newT = term1 - term2
        newNeg = left[3]
      } else {
        newT = term2 - term1
        newNeg = right[3]
      }
    }

    return [newP, newQ, newT, newNeg]
  }

  static sqrt(n, precision) {
    var scale = BigInt.powerOf10(precision * 2)
    var target = BigInt.new(n) * scale
    var x = BigInt.powerOf10(precision)
    for (i in 0..10) x = (x + (target / x)) / BigInt.new("2")
    return x
  }
}

class MachinPi {
  // Calculates arctan(1/d) scaled by 'scale'
  static arctan(d, scale) {
    var divisor = BigInt.new(d)
    var d2 = divisor * divisor

    // First term: scale / d
    var term = scale / divisor
    var result = term
    var n = 1

    while (term.toString != "0") {
      n = n + 2
      // Each subsequent term is (previous_term / d^2) * (prev_n / next_n)
      // but easier to just do: term = term / d^2
      term = term / d2

      var nextTerm = term / BigInt.new(n)

      if ((n / 2).floor % 2 == 1) {
        result = result - nextTerm
      } else {
        result = result + nextTerm
      }
    }
    return result
  }

  static calculate(digits) {
    // Add extra guard digits for intermediate calculations
    var precision = digits + 5
    var scale = BigInt.powerOf10(precision)

    // Pi = 4 * (4 * arctan(1/5) - arctan(1/239))
    var term1 = this.arctan(5, scale) * BigInt.new(4)
    var term2 = this.arctan(239, scale)

    var quarterPi = term1 - term2
    var pi = quarterPi * BigInt.new(4)

    var s = pi.toString
    s = s[0...-5] // Remove guard digits
    return s[0] + "." + s[1..-1]
  }
}

class GaussLegendrePi {
  static calculate(digits) {
    var extra = 10
    var precision = digits + extra
    var scale = BigInt.powerOf10(precision)
    var halfScale = BigInt.powerOf10(precision * 2)

    // Initial Values
    var a = scale                             // a_0 = 1
    var b = this.sqrt(5, precision) / BigInt.new(2) // b_0 = 1/sqrt(2) -> approx here
    // Note: To be precise, b_0 is sqrt(0.5). Let's use 1/sqrt(2):
    var two = BigInt.new(2) * halfScale
    var sqrt2 = this.sqrt(2, precision)
    b = (scale * scale) / sqrt2
    
    var t = scale / BigInt.new(4)             // t_0 = 1/4
    var p = BigInt.new(1)                     // p_0 = 1

    // Only 6 iterations are needed for 50-100 digits!
    for (i in 0..5) {
      var prevA = a
      a = (a + b) / BigInt.new(2)
      
      // Geometric mean: sqrt(a * b)
      var mult = prevA * b
      b = this.sqrtFromBigInt(mult, precision)
      
      var diff = prevA - a
      t = t - (p * (diff * diff) / scale)
      p = p * BigInt.new(2)
    }

    var finalNum = a + b
    var pi = (finalNum * finalNum) / (BigInt.new(4) * t)

    var s = pi.toString
    s = s[0...-extra]
    return s[0] + "." + s[1..-1]
  }

  // Helper to handle sqrt of a BigInt that is already scaled
  static sqrtFromBigInt(big, precision) {
    var x = BigInt.powerOf10(precision)
    for (i in 0..10) {
      x = (x + (big / x)) / BigInt.new(2)
    }
    return x
  }

  static sqrt(n, precision) {
    var target = BigInt.new(n) * BigInt.powerOf10(precision * 2)
    return this.sqrtFromBigInt(target, precision)
  }
}


System.print("Calculating Pi (50 digits)...")
System.print("Chudnovsky     : " + PiChudnovsky.calculate(50, 16))
System.print("Machin         : " + MachinPi.calculate(50))
System.print("Gauss Legendre : " + GaussLegendrePi.calculate(50))



