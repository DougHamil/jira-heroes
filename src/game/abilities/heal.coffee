HealAction = require '../actions/heal'
Errors = require '../errors'

class HealAbility
  constructor: (@model) ->
    @source = @model.source
    @data = @model.data

  getValidTargets: (battle) ->
    targets = []
    for fieldCard in battle.getFieldCards()
      targets.push fieldCard
    for hero in battle.getHeroes()
      targets.push hero
    return targets

  cast: (battle, target) ->
    if not target?
      throw Errors.INVALID_TARGET
    return [new HealAction(@source, target, @data.amount)]

module.exports = HealAbility
