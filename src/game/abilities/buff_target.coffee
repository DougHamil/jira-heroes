AddModifierAction = require '../actions/addmodifier'
Errors = require '../errors'

class BuffTargetAbility
  constructor: (@model) ->
    @source = @model.sourceCard
    @data = @model.data
    @model.modifierId = @model.modifierId || @model._id

  cast: (battle, target) ->
    throw Errors.INVALID_TARGET if not target?
    if target.isHero and @data.applyToHero? and not @data.applyToHero
      throw Errors.INVALID_TARGET
    return [new AddModifierAction(@model.modifierId, target, @data)]

module.exports = BuffTargetAbility
