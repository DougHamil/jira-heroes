###
# This file, and all files in lib/common are for logic shared between
# the server and client, hence the weird definitions so that they work with
# both RequireJS (browser) and CommonJS (server)
###
myExports = null
if not process? or not process.versions
  window.BattleHelpers = {}
  myExports = window.BattleHelpers
else
  myExports = exports
((exports) ->
  ###
  # Add some convenience methods to the card model
  ###
  _addCardMethods = (model) ->
    model.sumModifierProperty = (prop) ->
      if not @modifiers?
        return 0
      sum = 0
      for modifier in @modifiers
        if modifier.data? and modifier.data[prop]?
          sum += modifier.data[prop]
      return sum
    model.hasModifier = (modifierId) ->
      if not @modifiers?
        return false
      for modifier in @modifiers
        if modifier._id.toString() is modifierId.toString()
          return true
      return false
    model.hasRushAbility = (cardClass) ->
      return cardClass.rushAbility? and cardClass.rushAbility.class?
    model.getMaxHealth = ->
      return @maxHealth + @sumModifierProperty('maxHealth')
    model.getDamage = ->
      return @damage + @sumModifierProperty('damage')
    model.getEnergy = ->
      return @energy + @sumModifierProperty('energy')
    model.getStatus = ->
      status = []
      status = status.concat(@status)
      if @modifiers?
        # Add any status that were added via modifiers
        for modifier in @modifiers
          if modifier.data.addStatus?
            status.push modifier.data.addStatus
        # Remove any status that were removed via modifiers
        for modifier in @modifiers
          if modifier.data.removeStatus?
            idx = status.indexOf(modifier.data.removeStatus)
            if idx isnt -1
              status.splice(idx,1)
        # Remove all instances of status that are removed via modifiers
        for modifier in @modifiers
          if modifier.data.removeStatusAll?
            status = status.filter (s) -> s isnt modifier.data.removeStatusAll
      return status

  ###
  # Add some convenience methods to the hero model
  ###
  _addHeroMethods = (model) ->
    model.sumModifierProperty = (prop) ->
      if not @modifiers?
        return 0
      sum = 0
      for modifier in @modifiers
        if modifier.data? and modifier.data[prop]?
          sum += modifier.data[prop]
      return sum
    model.hasModifier = (modifierId) ->
      if not @modifiers?
        return false
      for modifier in @modifiers
        if modifier._id is modifierId
          return true
      return false
    model.getMaxHealth = ->
      return @maxHealth + @sumModifierProperty('maxHealth')
    model.getDamage = ->
      weaponDamage = if @weapon? then @weapon.damage else 0
      return weaponDamage + @damage + @sumModifierProperty('damage')
    model.getEnergy = ->
      return @energy + @sumModifierProperty('energy')
    model.getAbilityEnergy = ->
      return @abilityEnergy + @sumModifierProperty('ability-energy')
    model.getWeaponDurability = ->
      if not @weapon? or not @weapon.durability?
        return 0
      return @weapon.durability
    model.getStatus = ->
      status = []
      status = status.concat(@status)
      if @modifiers?
        # Add any status that were added via modifiers
        for modifier in @modifiers
          if modifier.data.addStatus?
            status.push modifier.data.addStatus
        # Remove any status that were removed via modifiers
        for modifier in @modifiers
          if modifier.data.removeStatus?
            idx = status.indexOf(modifier.data.removeStatus)
            if idx isnt -1
              status.splice(i,1)
        # Remove all instances of status that are removed via modifiers
        for modifier in @modifiers
          if modifier.data.removeStatusAll?
            status = status.filter (s) -> s isnt modifier.data.removeStatusAll
      return status
  _addMethodsToBattle = (model) ->
    for player in model.players
      for card in player.deck.cards
        _addCardMethods(card)
      _addHeroMethods(player.deck.hero)

  exports.addHeroMethods = _addHeroMethods
  exports.addCardMethods = _addCardMethods
  exports.addMethodsToBattle = _addMethodsToBattle
)(myExports)
