OverHealAction = require '../actions/overheal'
Errors = require '../errors'

class OverHealAbility
  constructor: (@model) ->
    @source = @model.sourceCard
    @data = @model.data

  cast: (battle, target) ->
    if not target?
      throw Errors.INVALID_TARGET
    return [new OverHealAction(@source, target, @data.amount)]

module.exports = OverHealAbility
