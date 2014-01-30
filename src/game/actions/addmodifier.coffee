###
# Adds a modifier to the target provided an ID, a target, and the modifier data
###
class AddModifierAction
  constructor: (@id, @target, @data) ->
    @modifier =
      _id: @id
      data:@data

  enact: (battle) ->
    @target.modifiers.push @modifier

    PAYLOAD =
      type: 'add-modifier'
      target: @target._id
      modifier: @modifier
    return [PAYLOAD]
module.exports = AddModifierAction
