HealAction = require '../actions/heal'
Errors = require '../errors'

class HealAbility
  constructor: (@model) ->
    @source = @model.sourceCard
    @data = @model.data

  cast: (battle, target) ->
    if not target?
      throw Errors.INVALID_TARGET
    return [new HealAction(@source, target, @data.amount)]

module.exports = HealAbility
