module.exports = class CardStatusRemoveAction
  constructor: (@card, @status) ->

  enact: (battle) ->
    if @status in @card.status
      @card.status = @card.status.filter (c) => c isnt @status
      PAYLOAD =
        type:'card-status-remove'
        card:@card._id
        status:@status
      return [PAYLOAD]
    return []
