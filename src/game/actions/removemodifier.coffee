###
# Removes the specified modifier from the target
###
class RemoveModifierAction
  constructor: (@id, @target) ->

  enact: (battle) ->
    preLength = @target.modifiers.length
    @target.modifiers = @target.modifiers.filter (m) => m._id is @id
    postLength = @target.modifiers.length

    # Only emit a payload if the modifier was actually removed
    if preLength > postLength
      PAYLOAD =
        type:'remove-modifier'
        target: @target._id
        modifier: @id
      return [PAYLOAD]
    return []

module.exports = RemoveModifierAction
