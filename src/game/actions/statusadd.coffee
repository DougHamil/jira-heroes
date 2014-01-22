AddModifierAction = require './addmodifier'

class StatusAddAction
  constructor:(@id, @target, @status) ->

  enact: (battle) ->
    modifierData =
      addStatus: @status
    action = new AddModifierAction(@id, @target, modifierData)
    return [null, [action]]

module.exports = StatusAddAction
