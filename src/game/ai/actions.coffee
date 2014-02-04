EndTurnAction = require '../actions/endturn'
Events = require '../events'

enact = (battle, cb) ->
  @build battle, (err, actions) =>
    if not err?
      payloads = battle.processActions actions
      battle.getActivePlayerHandler().emit @event, payloads
      cb null, payloads
    else
      cb err, []

class AIActions
  @EndTurnAction: (player) ->
    act =
      name:'EndTurnAction'
      event: Events.END_TURN
      debug:"End turn for #{player.userId}"
      enact: enact
      build: (battle, cb) -> cb null, [new EndTurnAction(player)]

  @PlayCardAction: (handler, targetHandler, card, target) ->
    targetName = targetHandler?.cardClass?.name
    if not targetName?
      targetName = targetHandler?.heroClass?.name
    if targetName?
      targetName = " on #{targetName}"
    act =
      name:'PlayCardAction'
      event:Events.PLAY_CARD
      debug: "Play card #{handler.cardClass.name} #{targetName}"
      enact:enact
      build: (battle, cb) ->
        cardHandler = battle.getCardHandler(card)
        target = battle.getCardOrHero(target)
        cardHandler.play target, (err, actions) =>
          if err?
            cb err, []
          else
            cb null, actions
    return act

  @UseCardAction: (handler, targetHandler, card, target) ->
    targetName = targetHandler?.cardClass?.name
    if not targetName?
      targetName = targetHandler?.heroClass?.name
      if targetName?
        targetName += " (#{targetHandler.model.userId})"
    if targetName?
      targetName = " on #{targetName}"
    act =
      name:'UseCardAction'
      event: Events.USE_CARD
      debug: "Use card #{handler?.cardClass?.name} #{targetName}"
      enact: enact
      build: (battle, cb) ->
        cardHandler = battle.getCardHandler(card)
        target = battle.getCardOrHero(target)
        cardHandler.use target, (err, actions) =>
          if err?
            cb err, []
          else
            cb null, actions

  @UseHeroAction: (hero, target) ->
    act =
      name:'UseHeroAction'
      event: Events.USE_HERO
      debug: "Use hero"
      enact: enact
      build: (battle, cb) ->
        heroHandler = battle.getHeroHandler(hero)
        target = battle.getCardOrHero(target)
        heroHandler.use target, (err, actions) =>
          if err?
            cb err, []
          else
            cb null, actions

  @HeroAttackAction: (hero, target) ->
    act =
      name:'HeroAttackAction'
      event: Events.HERO_ATTACK
      debug: "Attack with hero"
      enact: enact
      build: (battle, cb) ->
        heroHandler = battle.getHeroHandler(hero)
        target = battle.getCardOrHero(target)
        heroHandler.attack target, (err, actions) =>
          if err?
            cb err, []
          else
            cb null, actions

module.exports = AIActions
