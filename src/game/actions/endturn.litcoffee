	CardStatusRemoveAction = require './cardstatusremove'

EndTurnAction
===============
This action is invoked at the end of each turn
It should remove all sleeping statuses from field cards

Constructor
-----------
Constructed with the player model whose turn is ending

	module.exports = class EndTurnAction
		constructor: (@player) ->

Enact
-----------
Check all of the player's cards for the sleeping status and remove it

		enact: (battle) ->
			actions = []
			for card in battle.getFieldCards(@player)
				if 'sleeping' in card.status
					actions.push new CardStatusRemoveAction(card, 'sleeping')

Payload
------
Payload has `type` of **end-turn** and `player` property with the ID of the player whose turn is now over.
			PAYLOAD =
				type: 'end-turn'
				player: @player.userId

			return [PAYLOAD, actions]

