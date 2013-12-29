server = require '../server'
should = require 'should'
mongoose = require 'mongoose'
request = require 'request'
util = require '../util'
BattleController = require('../../lib/controllers/battle')(server.app, util.Users)
Battles = require '../../lib/models/battle'

describe 'BattleController', ->

  user = null
  it 'should create a new battle', (done) ->
    util.post '/secure/deck', {hero:'hacker', name:'deck'}, (err, res, body) ->
      res.should.have.status(200)
      deckId = JSON.parse(body)
      util.post '/secure/battle/host', {deck:deckId}, (err, res, body) ->
        should.not.exist(err)
        res.should.have.status(200)
        battle = JSON.parse(body)
        battle.should.have.property('_id')
        battle.users.should.have.length(1)
        battle.users.should.contain(user._id)
        util.get '/secure/user', (err, res, body) ->
          user = JSON.parse(body)
          user.should.have.property('activeBattle', battle._id)
          done()

  battleId = null
  it 'should return all battles', (done) ->
    util.get '/battle', (err, res, body) ->
      should.not.exist(err)
      res.should.have.status(200)
      battles = JSON.parse(body)
      battles.should.have.length(1)
      battleId = battles[0]._id
      done()

  it 'should return a specific battle', (done) ->
    util.get '/battle/'+battleId, (err, res, body) ->
      should.not.exist(err)
      res.should.have.status(200)
      battle = JSON.parse(body)
      battle.should.have.property('_id')
      done()

  # Setup server
  before (done) ->
    mongoose.connect 'mongodb://localhost/jira_heroes_test'
    util.login (err, res, body) ->
      util.get '/secure/user', (err, res, body) ->
        user = JSON.parse(body)
        done()

  after (done) ->
    util.Users.model.remove {}, ->
      Battles.model.remove {}, ->
        mongoose.disconnect()
        done()
