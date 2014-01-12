Events = require '../events'
HealAction = require '../actions/heal'
###
# This ability heals friendly units at the end of the player's turn
###
class EndTurnHealFriendly
  constructor: (@battle, @cardHandler, data) ->
    @amount = data.amount
    @healHero = data.healHero
    @playerHandler  = @cardHandler.playerHandler

  handle: (battle, actions) ->
    for action in actions
      if action instanceof EndTurnAction
        player = action.player
        if player is @playerHandler.player
          for minion in @playerHandler.getFieldCards()
            actions.push new HealAction(@cardHandler.model, minion, @amount)
          if @healHero?
            hero = @playerHandler.getHero()
            if hero.health < hero.maxHealth
              totalHealed = hero.maxHealth - hero.health
              if totalHealed > @amount
                totalHealed = @amount
              actions.push new HealAction(@cardHandler.model, hero, totalHealed)

module.exports = EndTurnHealFriendly
