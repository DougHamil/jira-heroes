HealAction = require '../actions/heal'

class HealAbility
  constructor: (@source, @data) ->

  cast: (battle, target) ->
    return [new HealAction(@source, target, @data.amount)]

module.exports = HealAbility
