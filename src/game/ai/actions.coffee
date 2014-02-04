EndTurnAction = require '../actions/endturn'
Events = require '../events'

enact = (battle, cb) ->
  @build battle, (err, actions) =>
    payloads = battle.processActions actions
    battle.getActivePlayerHandler().emit @event, payloads
    cb null, payloads

class AIActions
  @EndTurnAction: (player) ->
    act =
      name:'EndTurnAction'
      event: Events.END_TURN
      enact: enact
      build: (battle, cb) -> cb null, [new EndTurnAction(player)]

  @PlayCardAction: (card, target) ->
    act =
      name:'PlayCardAction'
      event:Events.PLAY_CARD
      enact:enact
      build: (battle, cb) ->
        cardHandler = battle.getCardHandler(card)
        cardHandler.play target, (err, actions) =>
          if err?
            cb err, []
          else
            cb null, actions
    return act

  @UseCardAction: (card, target) ->
    act =
      name:'UseCardAction'
      event: Events.USE_CARD
      enact: enact
      build: (battle, cb) ->
        cardHandler = battle.getCardHandler(card)
        cardHandler.use target, (err, actions) =>
          if err?
            cb err, []
          else
            cb null, actions

  @UseHeroAction: (hero, target) ->
    act =
      name:'UseHeroAction'
      event: Events.USE_HERO
      enact: enact
      build: (battle, cb) ->
        heroHandler = battle.getHeroHandler(hero)
        heroHandler.use target, (err, actions) =>
          if err?
            cb err, []
          else
            cb null, actions

  @HeroAttackAction: (hero, target) ->
    act =
      name:'HeroAttackAction'
      event: Events.HERO_ATTACK
      enact: enact
      build: (battle, cb) ->
        heroHandler = battle.getHeroHandler(hero)
        heroHandler.attack target, (err, actions) =>
          if err?
            cb err, []
          else
            cb null, actions

module.exports = AIActions
