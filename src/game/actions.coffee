PlayCardAction = require './actions/playcard'
PlayHeroAction = require './actions/playhero'
CastCardAction = require './actions/castcard'
CastRushAction = require './actions/castrush'
ConcedeAction = require './actions/concede'
CastHeroAbilityAction = require './actions/castheroability'
DiscardCardAction = require './actions/discardcard'
PermAddStatusAction = require './actions/permstatusadd'
DamageAction = require './actions/damage'

class Actions
  @AddStatus: (cardModel, status) ->
    return new PermAddStatusAction(cardModel, status)
  @CastCard: (cardModel, cardClass, target) ->
    return new CastCardAction(cardModel, cardClass, target)
  @CastHeroAbility: (heroModel, heroClass, target) ->
    return new CastHeroAbilityAction(heroModel, heroClass, target)
  @CastRush: (cardModel, cardClass, target) ->
    return new CastRushAction(cardModel, cardClass, target)
  @PlayCard: (cardModel, cardClass) ->
    return new PlayCardAction(cardModel, cardClass)
  @PlayHero: (heroModel, heroClass) ->
    return new PlayHeroAction(heroModel, heroClass)
  @DiscardCard: (cardModel) ->
    return new DiscardCardAction(cardModel)
  @Damage: (source, target, damage) ->
    return new DamageAction source, target, damage
  @Concede: (source) ->
    return new ConcedeAction source

  @_heroOrCard: (target) ->
    out = null
    if target.isHero?
      out =
        hero: target._id
    else
      out =
        card: target._id
    return out

module.exports = Actions
