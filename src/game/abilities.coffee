# Example ability class
class Ability
  constructor:(@source, @data) ->

  # Called when this ability should be casted on the given target
  cast: (battle, target) ->

  # Called on actively running abilities so that they may respond to new actions
  # Abilities can add/remove/alter the actions list
  handle: (battle, actions) ->

class Abilities
  @Attack: (sourceModel) ->
    return @New('attack', sourceModel)
  @New: (type, sourceModel, data) ->
    return new require('./abilities/'+type)(sourceModel, data)

module.exports = Abilities
