Front-end Architecture
======================
This document describes the client-side code structure.

Overview
=============
When the user is not currently in campaign mode, the interactions with the server will be done through simple AJAX requests. For instance, creating a hero will render the hero
creation menu but behind the scenes AJAX requests will download hero class information to provide to the user.
Once the user selects a hero and enters into campaign mode, a Socket.IO connection is made to the game server for that campaign.

In campaign mode all communication revolves around socket messages being passed from client to server.  All game logic resides on the server where the client is merely
the presentational and interaction layer. For instance, in battle mode the user will select one of his hero's abilities to cast, this will send a socket message to the
campaign server which will validate that the player can indeed cast that ability and then the message will be passed to all connected clients that the ability was cast.

Additionally, the game system is meant to allow easy dropping and reconnecting into campaigns and battles.  At any point during the campaign (whether in battle or not) a
player may close his browser, disconnecting his hero from the game.  Once detected, the server will tell all remaining clients that the hero has disconnected so that they
can present the information to the user.  But the player should be able to re-select his hero and jump right back into the battle in just the same state as when he left.
As soon as it's the disconnected player's turn, the battle is effectively stalled until the player returns.

To support this easy dropping in and out of games, the server needs to be able to easily store the entire state of any given campaign relatively often, in case the server goes down.
Additionally, upon connecting to a campaign, all of the campaign's current state should be serialized and sent to the client upon connecting.  From there, it should suffice to send
only differential updates.

Entity
-------
An entity is the base class for all units in the game (heroes and enemies).  It has basic information that are shared across all units
such as health and inventory. A PIXI Spine object is available for rendering any given entity.

Hero extends Entity
-------
The hero will also contain the amount of gold available to the hero and the currently unlocked abilities.

Item
-------
This class encapsulates all information regarding a single in-game item. This could be a weapon, a consumable, or clothing.  This object will have
a PIXI Sprite object for rendering.  Items can be held by heroes and will be rendered appropriately if equipped.

Ability
-------
The ability class contains information for rendering an entity's ability as well as what the ability actually does.

Campaign
---------
Contains information regarding the current campaign of the hero.
Should contain a way to render the map and how the hero can move around the map.
