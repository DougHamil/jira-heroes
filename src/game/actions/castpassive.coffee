###
# This action is used to package together the actions created by a passive ability
# This is considered a higher-order action
###
class CastPassiveAction
  constructor: (@source, @targets, @actions, @name) ->

  enact: (battle)->
    actions = []
    PAYLOAD =
      type: 'cast-passive'
      source: @source
      targets: @targets
      name: @name
    return [PAYLOAD, @actions]

module.exports = CastPassiveAction
