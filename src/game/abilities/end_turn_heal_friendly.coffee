Events = require '../events'
EndTurnAction = require '../actions/endturn'
HealAction = require '../actions/heal'
###
# This ability heals friendly units at the end of the player's turn
###
class EndTurnHealFriendly
  constructor: (@model) ->
    @amount = @model.data.amount
    @healHero = @model.data.healHero
    @healMinions = @model.data.healMinions
    @cardModel = @model.sourceCard

  respond: (battle, payloads, actions) ->
    player = battle.getPlayerOfCard(@cardModel)
    for payload in payloads
      if payload.type is 'end-turn' and payload.player is player.userId
        if @healMinions?
          for minion in battle.getFieldCards(player)
            actions.push new HealAction(@cardModel, minion, @amount)
        if @healHero?
          hero = battle.getHero(player)
          actions.push new HealAction(@cardModel, hero, @amount)
        return true
    return false

module.exports = EndTurnHealFriendly
