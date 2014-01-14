DiscardCardAction = require './discardcard'

class DestroyAction
  constructor: (@source, @target) ->

  enact: (battle) ->
    card = battle.getCardHandler(@target._id)
    hero = null
    actions = []
    if not card?
      hero = battle.getHero @target._id
    else
      actions.push new DiscardCardAction(@target)

    PAYLOAD =
      type: 'destroy'
      source: @source._id
    if card?
      PAYLOAD.card = @target._id
    else if hero?
      PAYLOAD.hero = @target._id
    return [PAYLOAD, actions]

module.exports = DestroyAction
