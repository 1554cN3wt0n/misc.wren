class Calendar {
  // Check if a year is a leap year
  static isLeap(y) { (y % 4 == 0 && y % 100 != 0) || (y % 400 == 0) }

  // Get number of days in a month
  static daysInMonth(m, y) {
    if (m == 2) return isLeap(y) ? 29 : 28
    if ([4, 6, 9, 11].contains(m)) return 30
    return 31
  }

  static monthName(m) {
    return ["January", "February", "March", "April", "May", "June", 
            "July", "August", "September", "October", "November", "December"][m - 1]
  }

  // Zeller's Congruence to find the start day (0=Sat, 1=Sun, ..., 6=Fri)
  // We'll adjust it to return 0=Sun, 1=Mon, ..., 6=Sat
  static startDay(m, y) {
    var d = 1
    if (m < 3) {
      m = m + 12
      y = y - 1
    }
    var k = y % 100
    var j = (y / 100).floor
    var h = (d + (13 * (m + 1) / 5).floor + k + (k / 4).floor + (j / 4).floor + 5 * j) % 7
    // Convert Zeller (Sat=0) to Sun=0
    return (h + 6) % 7
  }

  static display(m, y) {
    var title = "%(monthName(m)) %(y)"
    System.print(title)
    System.print("Su Mo Tu We Th Fr Sa")

    var start = startDay(m, y)
    var days = daysInMonth(m, y)
    
    var line = "   " * start
    var currentDay = start

    for (day in 1..days) {
      var dStr = day.toString
      if (dStr.count == 1) dStr = " " + dStr
      line = line + dStr + " "

      currentDay = currentDay + 1
      if (currentDay == 7) {
        System.print(line)
        line = ""
        currentDay = 0
      }
    }
    if (line != "") System.print(line)
  }
}

// --- Implementation ---
// Get current date (Approximate or hardcoded since Wren CLI lacks Date.now)
var month = 1
var year = 2026

Calendar.display(month, year)
