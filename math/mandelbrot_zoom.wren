class MandelbrotZoom {
  static draw(width, height, centerX, centerY, zoom) {
    var chars = " .:-;+*?\%S#@" // Reordered for better contrast on zoom
    
    // As zoom increases, the range (delta) decreases
    var range = 2.0 / zoom
    var minReal = centerX - range
    var maxReal = centerX + range
    var minImag = centerY - (range * (height / width)) // Adjust for terminal aspect ratio
    var maxImag = centerY + (range * (height / width))

    System.print("\e[H") // Move cursor to top
    System.print("Zoom: %(zoom) | Center: (%(centerX), %(centerY))")

    for (y in 0...height) {
      var row = ""
      for (x in 0...width) {
        var cr = minReal + (x / width) * (maxReal - minReal)
        var ci = minImag + (y / height) * (maxImag - minImag)
        
        var zr = 0.0
        var zi = 0.0
        var iterations = 0
        var maxIterations = 100 + (zoom.log * 20).floor // Increase detail as we zoom

        while (zr * zr + zi * zi <= 4.0 && iterations < maxIterations) {
          var temp = zr * zr - zi * zi + cr
          zi = 2.0 * zr * zi + ci
          zr = temp
          iterations = iterations + 1
        }

        if (iterations == maxIterations) {
          row = row + " " 
        } else {
          var charIdx = (iterations % chars.count)
          row = row + chars[charIdx]
        }
      }
      System.print(row)
    }
  }
}

// --- Coordinates to Explore ---
// 1. The "Seahorse Valley": centerX = -0.75, centerY = 0.1
// 2. The "Triple Spiral": centerX = -0.088, centerY = 0.654
// 3. The "Mini Mandelbrot": centerX = -1.75, centerY = 0

var z = 1.0
for (i in 0..5) {
    MandelbrotZoom.draw(80, 40, -0.75, 0.1, z)
    z = z * 2.0 // Double the zoom each frame
}
