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
  exports.addCardMethods = (model) ->
    model.sumModifierProperty = (prop) ->
      if not @modifiers?
        return 0
      sum = 0
      for modifier in @modifiers
        if modifier.data? and modifier.data[prop]?
          sum += modifier.data[prop]
      return sum
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
              status.splice(i,1)
        # Remove all instances of status that are removed via modifiers
        for modifier in @modifiers
          if modifier.data.removeStatusAll?
            status = status.filter (s) -> s isnt modifier.data.removeStatusAll
      return status

  ###
  # Add some convenience methods to the hero model
  ###
  exports.addHeroMethods = (model) ->
    model.sumModifierProperty = (prop) ->
      if not @modifiers?
        return 0
      sum = 0
      for modifier in @modifiers
        if modifier.data? and modifier.data[prop]?
          sum += modifier.data[prop]
      return sum
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
              status.splice(i,1)
        # Remove all instances of status that are removed via modifiers
        for modifier in @modifiers
          if modifier.data.removeStatusAll?
            status = status.filter (s) -> s isnt modifier.data.removeStatusAll
      return status
)(myExports)
