Events = require '../events'
HealAction = require '../actions/heal'
###
# This ability heals friendly units at the end of the player's turn
###
class EndTurnHealFriendly
  constructor: (@model) ->
    @amount = @model.data.amount
    @healHero = @model.data.healHero
    @cardModel = @model.sourceCard

  handle: (battle, actions) ->
    player = battle.getPlayerOfCard(@cardModel)
    for action in actions
      # Only heal if this player's turn is over
      if action instanceof EndTurnAction and player.userId is action.player
        for minion in battle.getFieldCards(player)
          actions.push new HealAction(@cardModel, minion, @amount)
        if @healHero?
          hero = battle.getHero(player)
          actions.push new HealAction(@cardModel, hero, @amount)
        break

module.exports = EndTurnHealFriendly
