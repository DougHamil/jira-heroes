	DestroyAction = require './destroy'

	class DamageAction

DamageAction
============
This action is responsible for reducing the health of a target
by a specified amount. If the health of the target is reduced to zero
or below, a [DestroyAction](./destroyaction.html) is created.

Constructor
-----------
Expects a `source` (either hero or card model), a `target` (either hero or card model),
and the amount of `damage` to inflict on the target on behalf of the source.

		constructor: (@source, @target, @damage) ->

Enact
-----------
Reduce the `target.health` by `damage` amount. If `target.health` is less than or equal to zero
then create a new [DestroyAction](./destroyaction.html).

		enact: (battle)->
			@target.health -= @damage
			actions = []
			if @target.health < 0
				actions.push new DestroyAction(@source, @target)

Payload
-----------
The payload has `type` of **damage**, with the `source`, `target`, and `damage`
			PAYLOAD =
				type: 'damage'
				source: @source._id
				target: @target._id
				damage: @damage
			return [PAYLOAD, actions]

	module.exports = DamageAction
