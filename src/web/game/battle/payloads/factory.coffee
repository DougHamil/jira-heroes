define [
  'battle/payloads/attack',
  'battle/payloads/playcard',
  'battle/payloads/castcard',
  'battle/payloads/castpassive',
  'battle/payloads/startturn',
  'battle/payloads/endturn',
  'util'], (
    AttackPayload,
    PlayCardPayload,
    CastCardPayload,
    CastPassivePayload,
    StartTurnPayload,
    EndTurnPayload,
    Util) ->
  PAYLOAD_CLASSES =
    'attack':AttackPayload
    'play-card':PlayCardPayload
    'cast-card':CastCardPayload
    'cast-passive':CastPassivePayload
    'start-turn':StartTurnPayload
    'end-turn':EndTurnPayload

  class PayloadFactory
    @processActions:(battle, actions) ->
      payloads = []
      while actions.length > 0
        action = actions.shift()
        try
          payloads.push @buildPayload(battle, action, actions)
        catch ex
          console.error "Could not build payload for action:"
          console.error action
          throw ex
      return payloads

    @isHigherOrderActionType: (type) -> return PAYLOAD_CLASSES[type]?

    @buildPayload: (battle, action, actions) ->
      payload = new PAYLOAD_CLASSES[action.type](action, battle)
      if actions.length > 0
        while actions.length > 0
          if not @isHigherOrderActionType(actions[0].type)
            next = actions.shift()
            payload.onAction(next)
          else
            break
      return payload
