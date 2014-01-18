class CardStatusAddAction
  constructor:(@card, @status) ->

  enact: (battle) ->
    if @status not in @card.status
      @card.status.push @status
      PAYLOAD =
        type:'card-status-add'
        card:@card._id
        status:@status
      return [PAYLOAD]
    else
      return []

module.exports = CardStatusAddAction
