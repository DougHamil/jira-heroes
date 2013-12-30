mongoose = require 'mongoose'
async = require 'async'
Schema   = mongoose.Schema
ObjectId = Schema.ObjectId
fs = require 'fs'
path = require 'path'

_schema = new Schema
  name:{type:String}
  displayName:{type:String}
  health: Number
  damage: Number
  media:
    icon: {type:String}

_model = mongoose.model('Hero', _schema)

_load = (cb) ->
  process.stdout.write 'Loading heroes...'
  appDir = path.join(process.cwd(), 'data/heroes')
  files = fs.readdirSync appDir
  loadCard = (file, cb) ->
    if file.indexOf('.swp') != -1
      cb null
    else
      data = JSON.parse(fs.readFileSync(path.join(appDir, file), 'utf8'))
      _model.findOneAndUpdate {name:data.name}, data, {upsert:true}, (err)->
        cb err
  async.each files, loadCard, (err) ->
    console.log 'Done!'
    cb err

_get = (id, cb) ->
  _model.findOne {_id:id}, cb

_getAll = (cb) ->
  _model.find {}, cb

_fromName = (name, cb) ->
  _model.findOne {name:name}, cb

module.exports =
  schema:_schema
  model:_model
  fromName: _fromName
  get:_get
  getAll:_getAll
  load:_load
