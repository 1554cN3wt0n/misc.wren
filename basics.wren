/*
  Wren Syntax Highlight & Features Tour
*/

// 1. Basic Variables and Types
var name = "Gemini"         // String
var age = 1                // Number (all numbers are double-precision floats)
var isFast = true          // Boolean
var empty = null           // Null

// 2. Collections (Lists and Maps)
var list = [1, 2, 3]       // Sequential list
list.add(5)
System.print(list)
list[3] = 4
System.print(list)

var map = { "color": "blue", "type": "AI" } // Key-Value pairs
map["color"] = "yellow"
System.print(map)

// 3. Control Flow
if (age < 10) {
  System.print("Still a young language.")
} else {
  System.print("Mature.")
}

// Ranges and Loops
for (i in 1..3) {          // 1..3 is inclusive. 1...3 excludes 3.
  System.print("Looping: %(i)") // String interpolation using %()
}

// 4. Classes (The heart of Wren)
class Robot {
  // The constructor
  construct new(model) {
    _model = model         // Variables starting with _ are private to the class
    _power = 100
  }

  // A Property (Getter)
  model { _model }

  // A Property (Setter)
  power=(value) {
    if (value < 0) value = 0
    _power = value
  }

  // Static method (Called on the class itself)
  static sayHello() {
    System.print("Bleep Bloop!")
  }

  // Instance method
  status() {
    System.print("Robot %(_model) is at %(_power)\% power.")
  }
}

// 5. Inheritance
class Drone is Robot {
  construct new(model, altitude) {
    super(model)           // Call parent constructor
    _alt = altitude
  }

  // Method Overriding
  status() {
    super.status()         // Call parent method
    System.print("Current altitude: %(_alt)m.")
  }
}

// 6. Using the Objects
Robot.sayHello()           // Static call

var myDrone = Drone.new("Sky-1", 500)
myDrone.power = 85         // Uses the setter
myDrone.status()           // Displays model, power, and altitude

// 7. Functional Style (Closures)
var square = Fn.new { |x| x * x }
System.print("Square of 4: %(square.call(4))")

var numbers = [1, 2, 3, 4]
var doubled = numbers.map { |n| n * 2 }.toList
System.print("Doubled: %(doubled)")
