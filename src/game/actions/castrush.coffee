PermStatusRemoveAction = require './permstatusremove'

###
# Used to indicate a card has used its rush ability
###
class CastRushAction
  constructor: (@cardModel, @cardClass, @targets) ->

  enact: (battle)->
    actions = [new PermStatusRemoveAction(@cardModel, 'can-rush')]
    PAYLOAD =
      type: 'cast-rush'
      player: @cardModel.userId
      card: @cardModel
      targets: @targets
    return [PAYLOAD, actions]

module.exports = CastRushAction
