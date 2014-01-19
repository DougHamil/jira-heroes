HealAction = require '../actions/heal'
Errors = require '../errors'

class HealAbility
  constructor: (@source, @data) ->

  cast: (battle, target) ->
    if not target?
      throw Errors.INVALID_TARGET
    return [new HealAction(@source, target, @data.amount)]

module.exports = HealAbility
