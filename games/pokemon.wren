import "io" for Stdin
import "random" for Random

var RNG = Random.new()

var ToUpper = Fn.new { |str| 
  var out = ""
  for (c in str.bytes) {
    if (c >= 97 && c <= 122) {
      out = out + String.fromByte(c - 32)
    } else {
      out = out + String.fromByte(c)
    }
  }
  return out
}

class Pokemon {
  construct new(name, type, hp, atk, def) {
    _name = name
    _type = type
    _maxHp = hp
    _hp = hp
    _atk = atk
    _def = def
    _moves = []
  }

  name { _name }
  type { _type }
  hp   { _hp }
  atk  { _atk }
  def  { _def }

  addMove(name, type, power) {
    _moves.add({ "name": name, "type": type, "power": power })
  }

  moves { _moves }
  takeDamage(amount) {
    _hp = (_hp - amount).max(0)
  }

  isFainted { _hp <= 0 }
}

class Battle {
  static getTypeEffectiveness(moveType, targetType) {
    var table = {
      "Fire":  {"Grass": 2.0, "Water": 0.5, "Fire": 0.5},
      "Water": {"Fire": 2.0, "Grass": 0.5, "Water": 0.5},
      "Grass": {"Water": 2.0, "Fire": 0.5, "Grass": 0.5}
    }
    if (table.containsKey(moveType) && table[moveType].containsKey(targetType)) {
      return table[moveType][targetType]
    }
    return 1.0
  }

  static executeTurn(attacker, defender, moveIndex) {
    var move = attacker.moves[moveIndex]
    var eff = getTypeEffectiveness(move["type"], defender.type)
    
    // Damage = (Atk/Def) * Power * Effectiveness * Random Variance
    var variance = 0.85 + (RNG.float() * 0.15)
    var damage = ((attacker.atk / defender.def) * move["power"] * eff * variance).floor
    
    defender.takeDamage(damage)

    System.print("\n--- %(attacker.name)'s Turn ---")
    System.print("%(attacker.name) used %(move["name"])!")
    if (eff > 1) System.print("It's super effective!")
    if (eff < 1 && eff != 1) System.print("It's not very effective...")
    System.print("%(defender.name) took %(damage) damage.")
  }
}

// --- Setup ---
var player = Pokemon.new("Charmander", "Fire", 50, 20, 10)
player.addMove("Ember", "Fire", 15)
player.addMove("Scratch", "Normal", 10)

var ai = Pokemon.new("Bulbasaur", "Grass", 60, 14, 15)
ai.addMove("Vine Whip", "Grass", 12)
ai.addMove("Tackle", "Normal", 8)

// --- Game Loop ---
System.print("A wild %(ai.name) appeared!")

while (!player.isFainted && !ai.isFainted) {
  // Display HUD
  System.print("\n================================")
  System.print("%(ToUpper.call(ai.name)) [HP: %(ai.hp)]")
  System.print("%(ToUpper.call(player.name)) [HP: %(player.hp)]")
  System.print("================================")
  
  // Player Phase
  System.print("Choose a move:")
  for (i in 0...player.moves.count) {
    System.print("%(i + 1): %(player.moves[i]["name"])")
  }
  
  var choice = -1
  while (choice < 0 || choice >= player.moves.count) {
    System.write("> ")
    var input = Stdin.readLine()
    var num = Num.fromString(input)
    if (num != null) choice = num - 1
  }

  Battle.executeTurn(player, ai, choice)
  
  if (ai.isFainted) {
    System.print("\n%(ai.name) fainted! You won the battle!")
    break
  }

  // AI Phase
  var aiMove = RNG.int(ai.moves.count)
  Battle.executeTurn(ai, player, aiMove)

  if (player.isFainted) {
    System.print("\n%(player.name) fainted... You blacked out!")
    break
  }
}
