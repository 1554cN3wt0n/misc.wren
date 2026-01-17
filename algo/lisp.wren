class Lisp {
  construct new() {
    _globalEnv = {
      "+": Fn.new {|args| args.reduce(0) {|a, b| a + b }},
      "-": Fn.new {|args| args[0] - args[1] },
      "*": Fn.new {|args| args.reduce(1) {|a, b| a * b }},
      ">": Fn.new {|args| args[0] > args[1] },
      "<": Fn.new {|args| args[0] < args[1] },
      "=": Fn.new {|args| args[0] == args[1] }
    }
  }

  tokenize(str) {
    return str.replace("(", " ( ").replace(")", " ) ").split(" ").where {|s| s != ""}.toList
  }

  readFromTokens(tokens) {
    var token = tokens.removeAt(0)
    if (token == "(") {
      var list = []
      while (tokens[0] != ")") list.add(readFromTokens(tokens))
      tokens.removeAt(0)
      return list
    } else {
      var num = Num.fromString(token)
      return (num != null) ? num : token
    }
  }

  // Evaluate an expression within a specific environment (env)
  eval(x, env) {
    if (x is Num) return x
    if (x is String) {
      if (!env.containsKey(x)) Fiber.abort("Variable '%(x)' not found.")
      return env[x]
    }

    // Special Forms
    var op = x[0]

    if (op == "define") { // (define x 10)
      var varName = x[1]
      var value = eval(x[2], env)
      env[varName] = value
      return value
    }

    if (op == "if") { // (if (> x 5) 1 0)
      var test = eval(x[1], env)
      return test ? eval(x[2], env) : eval(x[3], env)
    }

    if (op == "lambda") { // (lambda (x) (* x x))
      var params = x[1]
      var body = x[2]
      // Return a closure: a function that remembers the environment
      return Fn.new {|args|
        var localEnv = {}
        // Copy parent env (Lexical scoping)
        for (entry in env) localEnv[entry.key] = entry.value
        // Bind arguments to parameters
        for (i in 0...params.count) localEnv[params[i]] = args[i]
        return eval(body, localEnv)
      }
    }

    // Procedure Call: Evaluate operator and all arguments
    var proc = eval(op, env)
    var args = x.skip(1).map {|arg| eval(arg, env)}.toList
    return proc.call(args)
  }

  run(code) {
    var tokens = tokenize(code)
    var expression = readFromTokens(tokens)
    return eval(expression, _globalEnv)
  }
}

var lisp = Lisp.new()

// Define a variable
lisp.run("(define limit 50)")

// Define a squaring function and apply it conditionally
// "If 10 squared is greater than limit, return 1, else return 0"
var code = "(if (> ((lambda (x) (* x x)) 10) limit) 1 0)"

System.print("Result: " + lisp.run(code).toString) // Output: 1
