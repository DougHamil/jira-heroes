errors =
  NOT_YOUR_TURN: 'Not your turn'
  NOT_ACTIVE_PLAYER: 'Not active player'
  USER_NOT_LOGGED_IN: 'User is not logged in'
  INVALID_ACTION: 'Invalid action'
  INVALID_USER: 'Invalid user'
  INVALID_HERO: 'Invalid hero, the user does not own the provided hero ID'
  INVALID_CAMPAIGN: 'Invalid campaign'
  INVALID_GAME: 'Invalid game. Game not found'
  INVALID_TARGET: 'Target is not valid'
  NOT_ENOUGH_ENERGY: 'Not enough energy'
  DATABASE_ERROR: 'Error requesting some data'
  GAME_FULL: 'The game is full'
  INVALID_HERO_CLASS: 'Invalid hero class'
  INVALID_CAMPAIGN_CLASS: 'Invalid campaign class'
  HERO_ALREADY_IN_BATTLE: 'Hero is already in the battle, cannot re-enter'
  HERO_NOT_IN_BATTLE: 'Hero is not currently in the battle'
  HERO_NOT_IN_CAMPAIGN: 'Hero is not joined to the campaign'
  BATTLE_FULL: 'The battle already has max heroes'
  BATTLE_ALREADY_STARTED: 'The battle has already started'
  HERO_ALREADY_ON_CAMPAIGN: 'The hero is already on a campaign'
  HERO_ALREADY_JOINED: 'The user has already joined a campaign'
  INVALID_MOVE: 'Hero cannot move there'

errorObjs = {}
for id, message of errors
  errorObjs[id] =
    id: id
    message: message
    error: true

module.exports = errorObjs
