mongoose = require 'mongoose'
async = require 'async'
fs = require 'fs'
path = require 'path'

_schema = new mongoose.Schema
  name:{type:String}
  displayName:{type:String}
  health:{type:Number}
  damage:{type:Number}
  traits:[{type:String}]
  flags:[{type:String}]
  media:
    icon: {type:String}
    audio:
      attack:{type:String}
      hurt:{type:String}
      death:{type:String}

_model = mongoose.model 'Card', _schema

_load = (cb) ->
  dir = path.join process.cwd(), 'data/cards'
  files = fs.readdirSync dir
  loadFile = (file, cb) ->
    if file.indexOf('.swp') != -1
      cb null
    else
      console.log "Loading card #{file}"
      data = JSON.parse(fs.readFileSync(path.join(dir, file), 'utf8'))
      _model.findOneAndUpdate {name:data.name}, data, {upsert:true}, (err) ->
        cb err
  async.each files, loadFile, (err) ->
    cb err

_get = (id, cb) ->
  _model.findOne {_id:id}, cb

_getAll = (cb) ->
  _model.find {}, cb

module.exports =
  schema:_schema
  model:_model
  get:_get
  getAll:_getAll
  load:_load
