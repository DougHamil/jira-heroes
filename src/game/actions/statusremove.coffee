AddModifierAction = require './addmodifier'

###
# Adds a removeStatus modifier to the target
###
class StatusRemoveAction
  constructor: (@id, @target, @status) ->

  enact: (battle) ->
    modifierData =
      removeStatus: @status
    action = new AddModifierAction(@id, @target, modifierData)
    return [null, [action]]

module.exports = StatusRemoveAction
