mongoose = require 'mongoose'

_schema = new mongoose.Schema
  users: [{type:String}]
  players:[{type:mongoose.Schema.Types.Mixed}]     # Player ids and snapshots of each deck
  phase:{type:String}

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
