mongoose = require 'mongoose'
async = require 'async'
fs = require 'fs'
path = require 'path'
readdirp = require 'readdirp'

_schema = new mongoose.Schema
  name:{type:String}
  displayName: {type:String}
  description: {type:String}
  module:{type:String}
  earned:{type:Boolean, default:false}
  acknowledged: {type:Boolean, default:false}
  data: {}

_model = mongoose.model 'Achievement', _schema

_load = (cb) ->
  process.stdout.write 'Loading achievements...'
  dir = path.join process.cwd(), 'data/achievements'
  files = fs.readdirSync dir
  loadFile = (file, cb) ->
    if file.indexOf('.swp') != -1
      cb null
    else
      data = JSON.parse(fs.readFileSync(path.join(dir, file), 'utf8'))
      _model.findOneAndUpdate {name:data.name}, data, {upsert:true}, (err) ->
        cb err
  async.each files, loadFile, (err) ->
    console.log "Done!"
    cb err

_cache = null
_getAll = (cb) ->
  if not _cache?
    _model.find {}, (err, achieves) ->
      _cache = achieves
      cb err, achieves
  else
    cb null, _cache

module.exports =
  schema:_schema
  model:_model
  load:_load
  getAll:_getAll
