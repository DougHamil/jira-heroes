###
# Permanently adds a status to a target (ie not through modifiers)
###
class PermStatusAddAction
  constructor: (@target, @status) ->

  enact: (battle) ->
    if @status not in @target.status
      @target.status.push @status
      PAYLOAD =
        type:'status-add'
        target: @target._id
        status:@status
      return [PAYLOAD]
    return []

module.exports = PermStatusAddAction
