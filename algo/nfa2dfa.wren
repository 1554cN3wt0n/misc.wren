class DFAMinimizer {
  static minimize(dfa) {
    var alphabet = dfa["alphabet"]
    var states = dfa["states"]
    var accepting = dfa["accepting"]
    var transitions = dfa["transitions"]

    // 1. Initial Partition: Group 0 = Non-accepting, Group 1 = Accepting
    var partition = []
    var nonAccepting = states.where { |s| !accepting.contains(s) }.toList
    if (nonAccepting.count > 0) partition.add(nonAccepting)
    if (accepting.count > 0) partition.add(accepting.toList)

    var changed = true
    while (changed) {
      changed = false
      var newPartition = []

      for (group in partition) {
        if (group.count <= 1) {
          newPartition.add(group)
          continue
        }

        // Try to split this group
        var subgroups = {}
        for (state in group) {
          // Create a "signature" based on which group each transition leads to
          var signature = ""
          for (char in alphabet) {
            var dest = transitions[state][char]
            var groupIdx = this.findGroupIndex(partition, dest)
            signature = signature + "%(char):%(groupIdx)|"
          }
          
          if (!subgroups.containsKey(signature)) subgroups[signature] = []
          subgroups[signature].add(state)
        }

        var splitList = subgroups.values.toList
        for (sub in splitList) newPartition.add(sub)
        if (splitList.count > 1) changed = true
      }
      partition = newPartition
    }

    return this.buildMinimizedDFA(dfa, partition)
  }

  static findGroupIndex(partition, state) {
    for (i in 0...partition.count) {
      if (partition[i].contains(state)) return i
    }
    return -1
  }

  static buildMinimizedDFA(dfa, partition) {
    var newStates = []
    var newTransitions = {}
    var newAccepting = []
    var stateMap = {} // Old state -> New Group Key

    for (i in 0...partition.count) {
      var group = partition[i]
      var key = "G%(i)"
      newStates.add(key)
      for (s in group) stateMap[s] = key
      if (group.any { |s| dfa["accepting"].contains(s) }) newAccepting.add(key)
    }

    for (i in 0...partition.count) {
      var representative = partition[i][0]
      var key = "G%(i)"
      newTransitions[key] = {}
      for (char in dfa["alphabet"]) {
        var oldDest = dfa["transitions"][representative][char]
        newTransitions[key][char] = stateMap[oldDest]
      }
    }

    return {
      "alphabet": dfa["alphabet"],
      "states": newStates,
      "transitions": newTransitions,
      "start": stateMap[dfa["start"]],
      "accepting": newAccepting
    }
  }
}

class NFAtoDFA {
  static convert(nfa) {
    var alphabet = nfa["alphabet"]
    var nfaTransitions = nfa["transitions"]
    
    // Start with the epsilon closure of the start state
    var startState = this.epsilonClosure([nfa["start"]], nfaTransitions)
    var dfaStates = [startState]
    var dfaTransitions = {}
    var unprocessed = [startState]
    
    while (unprocessed.count > 0) {
      var currentSet = unprocessed.removeAt(0)
      var currentKey = this.getSetKey(currentSet)
      
      dfaTransitions[currentKey] = {}

      for (char in alphabet) {
        // Find all NFA states reachable from currentSet via 'char'
        var nextSet = []
        for (state in currentSet) {
          if (nfaTransitions[state] && nfaTransitions[state][char]) {
            for (ns in nfaTransitions[state][char]) {
              if (!nextSet.contains(ns)) nextSet.add(ns)
            }
          }
        }
        
        // Apply epsilon closure to the result
        nextSet = this.epsilonClosure(nextSet, nfaTransitions)
        
        if (nextSet.count > 0) {
          var nextKey = this.getSetKey(nextSet)
          dfaTransitions[currentKey][char] = nextKey
          
          // If this is a new set of states, add to unprocessed
          if (!dfaStates.any { |s| this.getSetKey(s) == nextKey }) {
            dfaStates.add(nextSet)
            unprocessed.add(nextSet)
          }
        }
      }
    }

    return {
      "states": dfaStates.map { |s| this.getSetKey(s) }.toList,
      "alphabet": alphabet,
      "transitions": dfaTransitions,
      "start": this.getSetKey(startState),
      "accepting": dfaStates.where { |set| 
        // We iterate through every NFA state in the DFA's combined set
        var isAccepting = false
        for (nfaState in set) {
          // Check if THIS specific NFA state is in the original accepting list
          if (nfa["accepting"].contains(nfaState)) {
            isAccepting = true
            break
          }
        }
        return isAccepting
      }.map { |s| this.getSetKey(s) }.toList
    }
  }

  // Helper to find all states reachable via empty transitions
  static epsilonClosure(states, transitions) {
    var closure = states.toList
    var stack = states.toList
    while (stack.count > 0) {
      var s = stack.removeAt(-1)
      if (transitions[s] && transitions[s]["epsilon"]) {
        for (next in transitions[s]["epsilon"]) {
          if (!closure.contains(next)) {
            closure.add(next)
            stack.add(next)
          }
        }
      }
    }
    // closure.sort()
    return closure
  }

  static getSetKey(set) { "{%(set.join(","))}" }
}

// --- Example: NFA for (a|b)*abb ---
var nfa = {
  "alphabet": ["a", "b"],
  "start": "q0",
  "accepting": ["q3"],
  "transitions": {
    "q0": { "a": ["q0", "q1"], "b": ["q0"] },
    "q1": { "b": ["q2"] },
    "q2": { "b": ["q3"] }
  }
}

var dfa = NFAtoDFA.convert(nfa)
System.print("DFA Start State: " + dfa["start"])
System.print("DFA Accepting States: " + dfa["accepting"].join(", "))
System.print("\nTransitions:")
for (from in dfa["transitions"].keys) {
  for (char in dfa["transitions"][from].keys) {
    System.print("%(from) --%(char)--> %(dfa["transitions"][from][char])")
  }
}

// --- Let's minimize the DFA we got from the NFA ---
var minDFA = DFAMinimizer.minimize(dfa)

System.print("Minimized DFA States: %(minDFA["states"].join(", "))")
System.print("Start: %(minDFA["start"])")
System.print("Accepting: %(minDFA["accepting"].join(", "))")

for (from in minDFA["transitions"].keys) {
  for (char in minDFA["alphabet"]) {
    var to = minDFA["transitions"][from][char]
    System.print("%(from) --%(char)--> %(to)")
  }
}
