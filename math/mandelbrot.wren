class Mandelbrot {
  static draw(width, height) {
    // Character set from "dense" to "light" to represent escape speed
    var chars = "@#S\%?*+;:-. "
    
    // The Mandelbrot set usually lives between x:[-2, 1] and y:[-1, 1]
    var minReal = -2.0
    var maxReal = 1.0
    var minImag = -1.2
    var maxImag = 1.2

    for (y in 0...height) {
      var row = ""
      for (x in 0...width) {
        // Map terminal coordinates (x, y) to complex plane (cr, ci)
        var cr = minReal + (x / width) * (maxReal - minReal)
        var ci = minImag + (y / height) * (maxImag - minImag)
        
        var zr = 0.0
        var zi = 0.0
        var iterations = 0
        var maxIterations = 100

        // The core Mandelbrot formula: z = z^2 + c
        while (zr * zr + zi * zi <= 4.0 && iterations < maxIterations) {
          var temp = zr * zr - zi * zi + cr
          zi = 2.0 * zr * zi + ci
          zr = temp
          iterations = iterations + 1
        }

        // Pick a character based on how many iterations it survived
        if (iterations == maxIterations) {
          row = row + " " // Inside the set
        } else {
          var charIdx = (iterations % chars.count)
          row = row + chars[charIdx]
        }
      }
      System.print(row)
    }
  }
}

// Clear screen and draw
System.print("\e[2J\e[H") 
// Width of 80 and Height of 40 is usually good for a standard terminal
Mandelbrot.draw(80, 40)
