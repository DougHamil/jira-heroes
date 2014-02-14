mongoose = require 'mongoose'
async = require 'async'
fs = require 'fs'
path = require 'path'
readdirp = require 'readdirp'

_abilitySchemaOpts =
  class:String
  requiresTarget: Boolean
  text:String
  data: {}
  fx: {}
_abilitySchema = new mongoose.Schema _abilitySchemaOpts

_schema = new mongoose.Schema
  name:{type:String}
  heroRequirement: [{type:String}]
  deckLimit: {type:Number, default: 10}
  cost:
    storyPoints:Number
    bugsClosed:Number
    bugsReported:Number
  hidden:{type:Boolean, default:false}
  energy: {type:Number}
  displayName:{type:String}
  health:{type:Number}
  damage:{type:Number}
  traits:[{type:String}]
  rushAbility: {}             # A minions's rush ability (battlecry)
  useAbility: {}              # A minions's attack ability
  playAbility: {}             # A spell card's ability
  passiveAbilities: [_abilitySchema]          # A card's passive abilities
  flags:[{type:String}]
  media:
    image: {type:String}
    fx:
      class:String
      data: {type:mongoose.Schema.Types.Mixed}
    audio:
      attack:{type:String}
      hurt:{type:String}
      death:{type:String}

_schema.methods.isSpellCard = ->
  return @playAbility? and @playAbility.class?

_schema.methods.isSpell = ->
  return @playAbility? and @playAbility.class?

_model = mongoose.model 'Card', _schema

_validateCardData = (data) ->
  # It is invalid for a card to be a rush card and have a rush ability
  if data.traits? and 'rush' in data.traits and data.rushAbility? and data.rushAbility.class?
    return new Error("Card #{data.name} has a rush trait and a rush ability, they are mutually exclusive. Please remove one.")
  checkAbilityProps = (abil) ->
    if abil? and abil.class? and not abil.requiresTarget?
      return new Error("Card #{data.name} is missing a 'requiresTarget' property on ability #{abil.class}")
  err = checkAbilityProps(data.playAbility)
  if err?
    return err
  err = checkAbilityProps(data.rushAbility)
  if err?
    return err
  return null

_load = (cb) ->
  process.stdout.write 'Loading cards...'
  dir = path.join process.cwd(), 'data/cards'

  loadFile = (file, cb) ->
    if file.indexOf('.swp') != -1
      cb null
    else if path.basename(path.dirname(file)) is 'test'
      cb null
    else
      data = JSON.parse(fs.readFileSync(file, 'utf8'))
      _model.findOne {name:data.name}, (err, stored) ->
        if err?
          cb err
        else
          if stored?
            if not data.passiveAbilities?
              stored.passiveAbilities = []
            for key, value of data
              stored[key] = value
              stored.markModified(key)
          else
            stored = new _model(data)
          validationError = _validateCardData(data)
          if validationError?
            throw validationError
          stored.save (err) ->
            cb err
      #_model.findOneAndUpdate {name:data.name}, data, {upsert:true}, (err) ->
      #  cb err

  files = []
  filestream = readdirp {root: dir, fileFilter: '*.json'}
  filestream.on 'data', (entry) ->
    files.push entry.fullPath
  filestream.on 'end', ->
    async.each files, loadFile, (err) ->
      console.log 'Done!'
      cb err

_get = (id, cb) ->
  if typeof id is 'string'
    _model.findOne {_id:id}, cb
  else
    _model.find({_id:{$in:id}}).exec cb

_getAll = (cb) ->
  _model.find {}, cb

_query = (query, cb) ->
  _model.find query, cb

module.exports =
  schema:_schema
  model:_model
  get:_get
  getAll:_getAll
  load:_load
  query:_query
