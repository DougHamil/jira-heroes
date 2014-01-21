mongoose = require 'mongoose'
async = require 'async'
CardCache = require './cardcache'
HeroCache = require './herocache'

# Transform a card model into a card instance
newCardInstance = (userId) ->
  (cardId, cb) ->
    CardCache.get cardId, (err, card) ->
      if err?
        cb err
      else
        out =
          usedRushAbility: false
          userId: userId
          position: 'deck'
          class:cardId
          health:card.health
          maxHealth:card.health
          damage:card.damage
          status: []
        cb null, out

# Transform a hero model into a hero instance
newHeroInstance = (userId, hero, cb) ->
  HeroCache.get hero.class, (err, heroClass) ->
    if err?
      cb err
    else
      out =
        _id:userId
        userId: userId
        class: heroClass._id
        health: heroClass.health
        maxHealth: heroClass.health
        damage: heroClass.damage
      cb null, out

# Transform a user and deck into a player instance
newPlayerInstance = (userId, deck, cb) ->
  newHeroInstance userId, deck.hero, (err, hero) ->
    if err?
      cb err
    else
      async.map deck.cards, newCardInstance(userId), (err, cards) ->
        if err?
          cb err
        else
          player =
            _id: userId
            userId: userId
            energy: 0
            maxEnergy: 0
            deck:
              hero: hero
              cards: cards
          cb null, player

# Represents a single card instance in a battle (health, damage, active effects)
_cardSchema = new mongoose.Schema
  class: String
  userId: String
  health: Number
  usedRushAbility: Boolean
  maxHealth: Number
  damage: Number
  status: [String]
  effects: [String]
  position: String

# Represents a user in a battle, contains their energy, their deck (with hero and cards)
_playerSchema = new mongoose.Schema
  _id:String
  userId: String
  energy: Number
  maxEnergy: Number
  deck:
    hero:
      userId: String
      _id: String
      class: String
      health: Number
      maxHealth: Number
      damage: Number
    cards: [_cardSchema]

# Represents a single battle
_schema = new mongoose.Schema
  users: [{type:String}]
  players: [_playerSchema]
  passiveAbilities: [mongoose.Schema.Types.Mixed]
  state:
    phase: {type:String, default:'initial'}
    activePlayer: String

# Get the data that the public endpoint can provide
_schema.methods.getPublicData = ->
  out =
    _id:@_id
    users:@users

_schema.methods.addPlayer = (userId, deck, cb) ->
  if not @players?
    @players = []
  newPlayerInstance userId, deck, (err, player) =>
    if err?
      cb err
    else
      @players.push player
      cb null, player

_model = mongoose.model 'Battle', _schema

_get = (id, cb) ->
  if id instanceof Array
    _model.find {_id: {$in:id}}, cb
  else
    _model.findOne {_id: id}, cb

_getAll = (cb) ->
  _model.find {}, cb

_create = (cb) ->
  battle = new _model()
  battle.save (err) ->
    cb err, battle

_query = (query, cb) ->
  _model.find query, cb

module.exports =
  cardSchema:_cardSchema
  playerSchema:_playerSchema
  schema:_schema
  model:_model
  create:_create
  get:_get
  getAll:_getAll
  query:_query
