mongoose = require 'mongoose'
async = require 'async'
CardCache = require './cardcache'
HeroCache = require './herocache'

# Transform a card model into a card instance
newCardInstance = (cardId, cb) ->
  CardCache.get cardId, (err, card) ->
    if err?
      cb err
    else
      out =
        class:cardId
        health:card.health
        damage:card.damage
        status: null
      cb null, out

# Transform a hero model into a hero instance
newHeroInstance = (hero, cb) ->
  HeroCache.get hero.class, (err, heroClass) ->
    if err?
      cb err
    else
      out =
        class: heroClass._id
        health: heroClass.health
        damage: heroClass.damage
      cb null, out

# Transform a user and deck into a player instance
newPlayerInstance = (userId, deck, cb) ->
  newHeroInstance deck.hero, (err, hero) ->
    if err?
      cb err
    else
      async.map deck.cards, newCardInstance, (err, cards) ->
        if err?
          cb err
        else
          player =
            userId: userId
            energy: 0
            deck:
              hero: hero
              cards: cards
          cb null, player

# Represents a single card instance in a battle (health, damage, active effects)
_cardSchema = new mongoose.Schema
  class: String
  health: Number
  damage: Number
  status: String
  effects: [String]

# Represents a user in a battle, contains their energy, their deck (with hero and cards)
_playerSchema = new mongoose.Schema
  userId: String
  energy: Number
  deck:
    hero:
      class: String
      health: Number
      damage: Number
    cards: [_cardSchema]

# Represents a single battle
_schema = new mongoose.Schema
  users: [{type:String}]
  players: [_playerSchema]
  state:
    phase: String

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
  _model.findOne {_id:id}, cb

_getAll = (cb) ->
  _model.find {}, cb

_create = (cb) ->
  battle = new _model()
  battle.save (err) ->
    cb err, battle

_query = (query, cb) ->
  _model.find query, cb

module.exports =
  schema:_schema
  model:_model
  create:_create
  get:_get
  getAll:_getAll
  query:_query
