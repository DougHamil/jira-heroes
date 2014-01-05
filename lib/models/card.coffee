mongoose = require 'mongoose'
async = require 'async'
fs = require 'fs'
path = require 'path'

_abilitySchema = new mongoose.Schema
  type:String
  text:String
  data: mongoose.Schema.Types.Mixed

_schema = new mongoose.Schema
  name:{type:String}
  cost: {type:Number}
  energy: {type:Number}
  displayName:{type:String}
  health:{type:Number}
  damage:{type:Number}
  traits:[{type:String}]
  abilities: [_abilitySchema]
  flags:[{type:String}]
  media:
    image: {type:String}
    audio:
      attack:{type:String}
      hurt:{type:String}
      death:{type:String}

_model = mongoose.model 'Card', _schema

_load = (cb) ->
  process.stdout.write 'Loading cards...'
  dir = path.join process.cwd(), 'data/cards'
  files = fs.readdirSync dir
  loadFile = (file, cb) ->
    if file.indexOf('.swp') != -1
      cb null
    else
      data = JSON.parse(fs.readFileSync(path.join(dir, file), 'utf8'))
      _model.findOneAndUpdate {name:data.name}, data, {upsert:true}, (err) ->
        cb err
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
