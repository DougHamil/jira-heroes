DamageAction = require '../actions/damage'
Errors = require '../errors'

class DamageAbility
  constructor: (@model) ->
    @source = @model.sourceCard
    @data = @model.data

  cast: (battle, target) ->
    if not target?
      throw Errors.INVALID_TARGET
    return [new DamageAction(@source, target, @data.amount)]

module.exports = DamageAbility
