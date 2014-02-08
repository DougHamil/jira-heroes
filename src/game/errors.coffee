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
  BATTLE_NOT_READY: 'The battle is not ready to play'
  BATTLE_FULL: 'The battle already has max heroes'
  BATTLE_ALREADY_STARTED: 'The battle has already started'
  HERO_ALREADY_ON_CAMPAIGN: 'The hero is already on a campaign'
  HERO_ALREADY_JOINED: 'The user has already joined a campaign'
  INVALID_MOVE: 'Hero cannot move there'
  CARD_SLEEPING: 'Card is sleeping, cannot be used until next turn'
  MUST_ATTACK_TAUNT: 'Must attack a taunt card'
  CARD_CANNOT_ATTACK: 'Card cannot attack'
  CARD_USED: 'Card has already been used this turn'
  HERO_USED: 'Hero has already been used this turn'
  HERO_ABILITY_USED: 'Hero\'s ability has already been used this turn'
  MUST_TARGET_TAUNT: 'You must target a taunt card'
  FROZEN: 'You cannot use a frozen card or hero'
  FULL_FIELD: 'Field is full, you cannot play any more minions on the field'
  NO_DAMAGE: 'Hero or card cannot attack because it does not have any damage'

errorObjs = {}
for id, message of errors
  errorObjs[id] =
    id: id
    message: message
    error: true
    jiraHeroesError: true

module.exports = errorObjs
