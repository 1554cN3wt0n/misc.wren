import "os" for Process

var PadRight = Fn.new {|s, width| 
    return s + " " * (width - s.count)
}

class PascalTriangle {
  static print(levels) {
    var row = [1] // Level 0
    
    for (i in 0...levels) {
      // 1. Center the row for a pretty triangle look
      var padding = "   " * (levels - i)
      var rowString = padding
      
      for (num in row) {
        // Pad numbers so the triangle stays aligned
        rowString = rowString + PadRight.call(num.toString, 6)
      }
      System.print(rowString)

      // 2. Calculate the next row
      var nextRow = [1] // Every row starts with 1
      for (j in 0...(row.count - 1)) {
        nextRow.add(row[j] + row[j+1])
      }
      nextRow.add(1) // Every row ends with 1
      
      row = nextRow
    }
  }
}

var args = Process.arguments

var levels = 10

if (args.count > 0) {
    levels = Num.fromString(args[0])
}

System.print("Pascal's Triangle (%(levels) Levels):")
PascalTriangle.print(levels)
