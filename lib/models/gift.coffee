mongoose = require 'mongoose'
async = require 'async'
Schema   = mongoose.Schema
ObjectId = Schema.ObjectId
fs = require 'fs'
path = require 'path'

_schema = new Schema
  from:String
  fromName:String
  to:String
  gift:
    storyPoints: {type:Number, default:0}
    bugsClosed: {type:Number, default:0}
    bugsReported: {type:Number, default:0}

_model = mongoose.model 'Gift', _schema

_get = (id, cb) ->
  _model.findOne {_id:id}, cb

_getFor = (userId, cb) ->
  _model.find {to:userId.toString()}, cb

_getFrom = (userId, cb) ->
  _model.find {from:userId.toString()}, cb

_remove = (id, cb) ->
  _model.remove {_id:id.toString()}, cb

_create = (from, fromName, to, giftAmount, cb) ->
  gift = new _model({from:from, fromName:fromName, to:to, gift:giftAmount})
  gift.save cb

module.exports =
  schema:_schema
  model:_model
  get:_get
  getGiftsFor: _getFor
  getGiftsFrom: _getFrom
  remove: _remove
  create: _create
