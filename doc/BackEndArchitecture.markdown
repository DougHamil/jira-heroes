Back-end Architecture
=====================

The backend is composed of two layers: web layer and the socket game-server layer.
All of the backend is based on NodeJS and will utilize express for the web-layer and Socket.IO for the game-server.

MongoDB will be used for persisting all game data. Mongoose will be used to introduce a schema for our objects and make querying information easier.

The web-layer will handle all game logic outside of the battle and campaign specific logic.  This includes creating heroes, spending/earning story points, and
tracking player stats. The campaign and battle logic will be handled by processing socket events in the game-server.

Web-layer logic will be primarily contained within "Controller" classes that will respond to web requests. Most controllers will be locked behind the login
so users must be authenticated before making any requests.

A bonus feature will be to provide an API for accessing any non-player specific information such as hero classes, abilities, and campaign classes. This will
permit others to utilize the Jira Heroes API for their own tools without requiring direct integeration in the Jira Heroes project. This information should not
be locked behind the login and should be freely available.
