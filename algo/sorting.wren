import "os" for Process
import "timer" for Timer
import "io" for Stdout

class Visualizer {
  // Renders the array as vertical bars
  static draw(array, highlightIdx) {
    System.write("\e[H") // Move cursor to top-left
    System.print("--- Wren Sorting Visualizer ---")
    
    var maxHeight = 20
    for (h in maxHeight..1) {
      var line = ""
      for (i in 0...array.count) {
        if (array[i] >= h) {
          // Highlight the element currently being moved/compared
          if (i == highlightIdx) {
            line = line + "\e[31m█ \e[0m" // Red bar
          } else {
            line = line + "█ "          // White bar
          }
        } else {
          line = line + "  "
        }
      }
      System.print(line)
    }
    System.print("-" * (array.count * 2))
    Timer.sleep(50) // Adjust speed here (ms)
  }
}

class Sorters {
  // 1. Bubble Sort: O(n^2) - The "Sinking" Sort
  static bubble(arr) {
    var n = arr.count
    for (i in 0...n) {
      for (j in 0...(n - i - 1)) {
        if (arr[j] > arr[j + 1]) {
          var temp = arr[j]
          arr[j] = arr[j + 1]
          arr[j + 1] = temp
          Visualizer.draw(arr, j + 1)
        }
      }
    }
  }

  // 2. Insertion Sort: O(n^2) - Like sorting playing cards
  static insertion(arr) {
    for (i in 1...arr.count) {
      var key = arr[i]
      var j = i - 1
      while (j >= 0 && arr[j] > key) {
        arr[j + 1] = arr[j]
        j = j - 1
        Visualizer.draw(arr, j + 1)
      }
      arr[j + 1] = key
      Visualizer.draw(arr, j + 1)
    }
  }

  // 3. Quick Sort: O(n log n) - Divide and Conquer
  static quick(arr) {
    quickSortHelper(arr, 0, arr.count - 1)
  }

  static quickSortHelper(arr, low, high) {
    if (low < high) {
      var p = partition(arr, low, high)
      quickSortHelper(arr, low, p - 1)
      quickSortHelper(arr, p + 1, high)
    }
  }

  static partition(arr, low, high) {
    var pivot = arr[high]
    var i = low
    for (j in low...high) {
      if (arr[j] < pivot) {
        var temp = arr[i]
        arr[i] = arr[j]
        arr[j] = temp
        i = i + 1
        Visualizer.draw(arr, i)
      }
    }
    var temp = arr[i]
    arr[i] = arr[high]
    arr[high] = temp
    Visualizer.draw(arr, i)
    return i
  }
}

// --- Main Execution Logic ---

var args = Process.arguments
if (args.count < 1) {
  System.print("Usage: wren script.wren [bubble|insertion|quick]")
} else {
  var mode = args[0]
  var data = [10, 2, 18, 5, 12, 1, 15, 7, 3, 20, 8, 4, 14, 6, 11, 9, 13, 17, 16, 19]
  
  System.print("\e[2J") // Initial screen clear
  if (mode == "bubble") { 
      Sorters.bubble(data) 
  } else if (mode == "insertion") { 
      Sorters.insertion(data) 
  } else if (mode == "quick") { 
      Sorters.quick(data) 
  } else { 
      System.print("\nalgorithm not supported") 
  }
  System.print("\nSorting Complete!")
}
