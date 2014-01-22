###
# Permanently removes a status from a target. (ie not done through modifiers)
###
class PermStatusRemoveAction
  constructor: (@target, @status) ->

  enact: (battle) ->
    if @status in @target.status
      @target.status = @target.status.filter (s) => s isnt @status
      PAYLOAD =
        type:'status-remove'
        target: @target._id
        status:@status
      return [PAYLOAD]
    return []

module.exports = PermStatusRemoveAction
