Events
==========

Client to Server
===============
join(heroId, campaignId) -> (err, campaignData)
	-- Joins a campaign as a hero, this must be called before any other events
move(nodeId) -> (nodeId/err)
	-- Moves a hero to a position on campaign board
enterBattle() -> (battleId/err)
	-- Enters the battle at the node the hero is currently on


Server to Client
================
These events are sent to the client by the server when other heroes are
doing various actions. Commonly they take the form of "hero<Verb>ed" where
the verb is an action that the player would send to the server.

heroJoined(heroData)
	-- Another hero has connected to the campaign (actually made socket connection)
heroMoved(heroId, nodeId)
	-- Another hero has moved to the specified position
heroEnteredBattle(heroId, battleId)
	-- Another hero has entered into a battle
battleStarted(battleId)
	-- The battle specified by the ID has started (called once a battle is full)


