mongoose = require 'mongoose'

_schema = new mongoose.Schema
  players:[{type:mongoose.Schema.Types.Mixed}]     # Player ids and snapshots of each deck
  phase:{type:String}

_model = mongoose.model 'Battle', _schema

_get = (id, cb) ->
  _model.findOne {_id:id}, cb

_create = (cb) ->
  battle = new _model()
  battle.save (err) ->
    cb err, battle

module.exports =
  schema:_schema
  model:_model
  create:_create
  get:_get
