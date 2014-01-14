	class DestroyAction

DestroyAction
=============
This action is invoked when a card or hero should be destroyed due to being killed.

Constructor
------------
Expecteds a source and target, where the source is the object responsible for killing the target.
		constructor: (@sourceModel, @targetModel) ->

Enact
---------
Simply create a payload indicating which card or hero was destroyed. If a card is destroyed, then discard the card (move to hand and unregister its abilities)

		enact: (battle) ->
			card = battle.getCardHandler(@targetModel._id)
			hero = null
			if not card?
				hero = battle.getHero @targetModel._id
			else
				card.discard()

Payload
-----------
Has type **destroy**, source is the ID of the hero or card that killed the target.
If a card was destroyed, then the payload will have a `card` property with the card, otherwise a `hero` property will have the ID of the hero that was destroyed.

			PAYLOAD =
				type: 'destroy'
				source: @source._id
			if card?
				PAYLOAD.card = @targetModel._id
			else if hero?
				PAYLOAD.hero = @targetModel._id
			return [PAYLOAD]

	module.exports = DestroyAction
