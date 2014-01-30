AddModifierAction = require '../actions/addmodifier'

class BuffTargetAbility
  constructor: (@model) ->
    @source = @model.sourceCard
    @data = @model.data
    @model.modifierId = @model.modifierId || @model._id

  cast: (battle, target) ->
    throw Errors.INVALID_TARGET if not target?
    return [new AddModifierAction(@model.modifierId, target, @data)]

module.exports = BuffTargetAbility
