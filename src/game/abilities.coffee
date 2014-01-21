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
  @Attack: (sourceCard) -> return @New('attack', sourceCard)

  @New: (type, sourceCard, data) ->
    clazz = require('./abilities/'+type)
    model =
      class:type
      data:data
      sourceCard: sourceCard
    return new clazz(model, false)

  # Restore an ability instance from a model
  @FromModel: (model) ->
    clazz = require('./abilities/'+model.class)
    return new clazz(model, true)

module.exports = Abilities
