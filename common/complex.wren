class Complex {
  construct new(re, im) {
    _re = re
    _im = im
  }
  re { _re }
  im { _im }

  +(o) { Complex.new(_re + o.re, _im + o.im) }
  -(o) { Complex.new(_re - o.re, _im - o.im) }
  
  *(o) {
    var re = _re * o.re - _im * o.im
    var im = _re * o.im + _im * o.re
    return Complex.new(re, im)
  }

  /(o) {
    var d = o.re * o.re + o.im * o.im
    return Complex.new((_re * o.re + _im * o.im) / d, (_im * o.re - _re * o.im) / d)
  }

  abs { (_re * _re + _im * _im).sqrt }
  
  toString {
    var sign = (_im >= 0) ? "+" : "-"
    return "%(_re) %(sign) %(_im.abs)i"
  }
}
