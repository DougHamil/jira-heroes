Events = require '../events'
CastPassiveAction = require '../actions/castpassive'
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

  getValidTargets: -> return null

  respond: (battle, payloads, actions) ->
    if 'frozen' not in @cardModel.getStatus()
      player = battle.getPlayerOfCard(@cardModel)
      for payload in payloads
        if payload.type is 'end-turn' and payload.player is player.userId
          myActions = []
          targets = []
          if @healMinions? and @healMinions
            for minion in battle.getFieldCards(player)
              myActions.push new HealAction(@cardModel, minion, @amount)
              targets.push minion
          if @healHero? and @healHero
            hero = battle.getHero(player)
            myActions.push new HealAction(@cardModel, hero, @amount)
            targets.push hero
          if myActions.length > 0
            actions.push new CastPassiveAction(@cardModel, targets, myActions, 'heal-all-friendly')
          return true
    return false

module.exports = EndTurnHealFriendly
