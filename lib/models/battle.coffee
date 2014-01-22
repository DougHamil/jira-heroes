mongoose = require 'mongoose'
async = require 'async'
CardCache = require './cardcache'
HeroCache = require './herocache'
BattleHelpers = require '../common/battlehelpers'

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
          energy:card.energy
          health:card.health
          maxHealth:card.health
          damage:card.damage
          used: false
          status: []
          modifiers: []
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
        modifiers: []
        status: []
        used:false
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

# Represents a single stat modifier to either a card or a hero.
_modifierSchema = new mongoose.Schema
  _id: String
  data: mongoose.Schema.Types.Mixed

# Represents a single card instance in a battle (health, damage, active effects)
_cardSchema = new mongoose.Schema
  class: String
  userId: String
  health: Number
  energy: Number
  usedRushAbility: Boolean
  maxHealth: Number
  damage: Number
  modifiers: [_modifierSchema]
  status: [String]
  effects: [String]
  position: String
  used: Boolean

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
      status: [String]
      modifiers: [_modifierSchema]
      used: Boolean
    cards: [_cardSchema]

# Represents a single battle
_schema = new mongoose.Schema
  users: [{type:String}]
  players: [_playerSchema]
  passiveAbilities: [mongoose.Schema.Types.Mixed]
  abilityId: {type:Number, default:0}
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

_addMethodsToModels = (cb) ->
  (err, models) ->
    if err?
      cb err
    else
      addToModel = (battleModel) ->
        for player in battleModel.players
          for card in player.deck.cards
            BattleHelpers.addCardMethods(card)
          BattleHelpers.addHeroMethods(player.deck.hero)
      if models instanceof Array
        for model in models
          addToModel(model)
      else
        addToModel(models)
      cb null, models

_get = (id, cb) ->
  if id instanceof Array
    _model.find {_id: {$in:id}}, _addMethodsToModels(cb)
  else
    _model.findOne {_id: id}, _addMethodsToModels(cb)

_getAll = (cb) ->
  _model.find {}, _addMethodsToModels(cb)

_create = (cb) ->
  battle = new _model()
  battle.save (err) ->
    _addMethodsToModels(cb)(err, battle)

_query = (query, cb) ->
  _model.find query, _addMethodsToModels(cb)

module.exports =
  cardSchema:_cardSchema
  playerSchema:_playerSchema
  schema:_schema
  model:_model
  create:_create
  get:_get
  getAll:_getAll
  query:_query
