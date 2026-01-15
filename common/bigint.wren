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
  
  // precision = number of decimal places wanted
  static trueDiv(numerator, denominator, precision) {
    // 1. Scale the numerator: numerator * 10^precision
    var factor = BigInt.powerOf10(precision)
    var scaledNumerator = numerator * factor

    // 2. Perform integer division
    var res = scaledNumerator.divMod(denominator)
    var quotient = res[0].toString

    // 3. Handle the decimal point placement
    if (quotient.count <= precision) {
      // Pad with leading zeros if the result is < 1 (e.g., "0.00123")
      while (quotient.count < precision) quotient = "0" + quotient
      return "0." + quotient
    } else {
      var splitAt = quotient.count - precision
      return quotient[0...splitAt] + "." + quotient[splitAt..-1]
    }
  }

  toString {
    var s = ""
    for (i in _digits.count-1..0) s = s + _digits[i].toString
    return s == "" ? "0" : s
  }
}

