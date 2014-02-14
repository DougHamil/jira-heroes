class RevealCardAction
  constructor: (@target) ->

  enact: (battle)->
    PAYLOAD =
      type: 'reveal-card'
      card: @target
      player: @target.userId
    return [PAYLOAD]

module.exports = RevealCardAction
