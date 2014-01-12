# Example ability class
class Ability
  constructor:(@battle, @cardHandler, @data) ->

  # Called during an event, this should return true if the rest of the abilities
  # should continue processing, false if this ability pre-empts other abilities
  onEvent: (event, actions, args...) ->

class Abilities
  @attack: (battle, cardHandler) ->
    return @fromType('attack', battle, cardHandler)
  @fromType: (type, battle, cardHandler, data) ->
    return new require('./abilities/'+type)(battle, cardHandler, data)

module.exports = Abilities
