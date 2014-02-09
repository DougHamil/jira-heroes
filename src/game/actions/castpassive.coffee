###
# This action is used to package together the actions created by a passive ability
# This is considered a higher-order action
###
class CastPassiveAction
  constructor: (@source, @targets, @actions, @fx) ->

  enact: (battle)->
    actions = []
    PAYLOAD =
      type: 'cast-passive'
      source: @source
      targets: @targets
      fx:@fx
    return [PAYLOAD, @actions]

module.exports = CastPassiveAction
