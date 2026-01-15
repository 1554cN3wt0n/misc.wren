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

class EulerCalculator {
  static calculate(digits) {
    // Add extra guard digits to maintain precision during many additions
    var extra = 10
    var precision = digits + extra
    var scale = BigInt.powerOf10(precision)

    // Initial state: e = 1/0! + 1/1! = 1 + 1 = 2
    var e = scale * BigInt.new(2)
    var term = scale // Initial term is 1/1! = 1
    
    var n = 2
    while (true) {
      // term = term / n
      term = term / BigInt.new(n)
      
      if (term.toString == "0") break // Stop when the term is smaller than our precision
      
      e = e + term
      n = n + 1
      
      // Optional: print progress for long calculations
      if (n % 10 == 0) System.print("Calculating... reached term 1/%(n)!")
    }

    var s = e.toString
    s = s[0...-extra] // Remove guard digits
    return s[0] + "." + s[1..-1]
  }
}

System.print("Calculating e to 50 digits...")
System.print(EulerCalculator.calculate(50))
