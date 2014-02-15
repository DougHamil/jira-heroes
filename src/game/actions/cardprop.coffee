###
# Adds a modifier to the target provided an ID, a target, and the modifier data
###
class CardPropAction
  constructor: (@target, @prop, @value) ->

  enact: (battle) ->
    if not @target.properties?
      @target.properties = {}
    @target.properties[@prop] = @value
    PAYLOAD =
      type: 'card-prop'
      target:@target._id
      property:@prop
      value:@value
    return [PAYLOAD]
module.exports = CardPropAction
