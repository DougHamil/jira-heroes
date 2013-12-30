mongoose = require 'mongoose'
Schema = mongoose.Schema

_schema = new Schema
  user: {type:String, default:null}
  name: {type:String, default:"Deck"}
  hero:
    class: {type:String}
  cards: [{type:String}]

_model = mongoose.model 'Deck', _schema

_get = (id, cb) ->
  _model.findOne {_id:id}, cb

_create = (cb) ->
  deck = new _model()
  deck.hero = {}
  deck.save (err) ->
    cb err, deck

module.exports =
  schema:_schema
  model:_model
  get:_get
  create:_create
