CardCache = require '../../lib/models/cardcache'
Errors = require './errors'

class CardHandler
  @playCard: (battle, player, card, cardClass, target) ->
    if target?
      if target.card?
        target = battle.getCard target.card
      else
        target = battle.getHero target.hero
    if player.player.energy >= cardClass.energy
      card.position = 'field'
      player.model.energy -= cardClass.energy
      # If the card doesn't have rush, then it is sleeping on first play
      if 'rush' not in cardClass.traits
        card.status.push 'sleeping'
      # Taunt cards have the taunt trait
      if 'taunt' in cardClass.traits
        card.status.push 'taunt'
      actions = []
      if target?
        actions = actions.concat(@_useDeployAbilities(battle, player, card, cardClass, target))
      return [null, actions]
    else
      return [Errors.NOT_ENOUGH_ENERGY]

  @updateFieldCardsOnTurn: (fieldCards) ->
    # On the next turn, remove the sleeping trait
    for card in fieldCards
      card.status = card.status.filter (t) -> t isnt 'sleeping'

  @useCardOnCard: (battle, player, card, target) ->
    # Sleeping cards may not attack
    if 'sleeping' in card.status
      return [Errors.CARD_SLEEPING]
    else
      CardCache.get card.class, (err, cardClass) ->
        CardCache.get target.class, (err, targetClass) ->
          actions = []
          # Is this an attack on an opponent's card?
          if card.userId isnt target.userId
            if card.damage > 0
              return @_attackCard battle, player, card, target
            else
              return @_useAbilityOnCard battle, player, card, cardClass, target, targetClass
          else
            return [null, actions]

  @_useAbilityOnCard: (battle, player, card, cardClass, target, targetClass) ->
    actions = []
    for ability in cardClass.abilities
      if ability.type is 'heal'
        healAmount = ability.data.amount
        target.health += healAmount
        # Cap health to original health
        if target.health > target.maxHealth
          target.health = target.maxHealth
    return [null, actions]

  @_useDeployAbilities: (battle, player, card, cardClass, target) ->
    actions = []
    for ability in cardClass.abilities
      if ability.type is 'buff'
        health = ability.data.health
        damage = ability.data.damage
        target = ability.data.target
        cardsToBuff = []
        if target is 'friendlies'
          cardsToBuff = player.getFieldCards()
        else if target is 'enemies'
          for p in @battle.getOtherPlayers player
            cardsToBuff = cardsToBuff.concat(p.getFieldCards())
        else if target is 'all'
          for _, p of @battle.players
            cardsToBuff = cardsToBuff.concat(p.getFieldCards())
        for fieldCard in cardsToBuff
          fieldCards.health += health
          fieldCards.maxHealth += health
          fieldCards.damage += damage
          actions.push @buildBuffAction(card, fieldCard, health, damage)
    return actions

  @_attackCard: (battle, player, source, target) ->
    targetPlayer = battle.getPlayer target.userId
    tauntCards = targetPlayer.getTauntCardsOnField()
    # Check if the target is a taunt card
    if tauntCards.length > 0 and target not in tauntCards
      return [Errors.MUST_ATTACK_TAUNT]
    else
      if card.damage > 0
        target.health -= card.damage
        actions.push @buildCardDamageAction(card.damage, card, target)
        if target.health <= 0
          target.position = 'discard'
          actions.push @buildCardKillAction(card, target)
        return [null, actions]
      else
        return [Errors.CARD_CANNOT_ATTACK]

  @buildBuffCardAction: (source, target, health, damage) ->
    out =
      type: 'buff'
      source: {card:source._id}
      target: {card:target._id}
      health: health
      damage: damage

  @buildCardDamageAction: (damage, source, target) ->
    out =
      type: 'damage'
      source: {card:source._id}
      target: {card:target._id}
      damage: damage

  @buildCardKillAction: (source, target) ->
    out =
      type:'kill'
      source: {card: source._id}
      target: {card: target._id}

module.exports = CardHandler
