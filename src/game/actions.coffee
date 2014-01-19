PlayCardAction = require './actions/playcard'
CastCardAction = require './actions/castcard'
DiscardCardAction = require './actions/discardcard'
DamageAction = require './actions/damage'

class Actions
  @CastCard: (cardModel, cardClass) ->
    return new CastCardAction(cardModel, cardClass)
  @PlayCard: (cardModel, cardClass) ->
    return new PlayCardAction(cardModel, cardClass)
  @DiscardCard: (cardModel) ->
    return new DiscardCardAction(cardModel)
  @Damage: (source, target, damage) ->
    return new DamageAction source, target, damage

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
