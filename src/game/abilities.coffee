
# Example ability class
class Ability
  # Model contains a data object, a sourceCard object, and a class.
  # isRestored is true if this ability is being restored from a peristed state
  constructor:(@model, isRestored) ->

  # Called when this ability should be casted on the given target
  cast: (battle, target) ->

  # Called on actively running abilities so that they may respond to new actions
  # Abilities can add/remove/alter the actions list
  handle: (battle, actions) ->

class Abilities
  @cache: {}
  @Attack: (abilityId, sourceCard) -> return @New(abilityId, 'attack', sourceCard)

  @New: (abilityId, type, sourceCard, data) ->
    if not @cache[type]
      @cache[type] = require('./abilities/'+type)
    clazz = @cache[type]
    # Stupid clone
    if data?
      data = JSON.parse(JSON.stringify(data))
    model =
      _id: abilityId
      class:type
      data:data
      sourceId: sourceCard._id
      source: sourceCard
    return new clazz(model, false)

  @NewFromModel: (abilityId, sourceCard, model) ->
    return @New(abilityId, model.class, sourceCard, model.data)

  # Restore an ability instance from a model
  @RestoreFromModel: (sourceCard, model) ->
    if not @cache[model.class]?
      @cache[model.class] = require('./abilities/'+model.class)
    clazz = @cache[model.class]
    model.source = sourceCard
    return new clazz(model, true)

module.exports = Abilities
