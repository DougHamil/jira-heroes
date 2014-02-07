should = require 'should'
request = require 'request'
util = require '../util'
Battles = require '../../lib/models/battle'

describe.skip 'BattleController', ->

  user = null
  it 'should create a new battle', (done) ->
    util.createDeck (err, deckId) ->
      should.not.exist(err)
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
  deckId = null
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

  it 'should allow a user to join an existing battle', (done) ->
    util.loginAs 'battletest', 'pass', (err, res, user) ->
      should.not.exist(err)
      util.createDeck (err, _deckId) ->
        should.not.exist(err)
        deckId = _deckId
        postdata =
          deck: deckId
        util.post "/secure/battle/#{battleId}/join", postdata, (err, res, body) ->
          should.not.exist(err)
          res.should.have.status(200)
          battle = JSON.parse(body)
          battle._id.should.eql(battleId)
          done()

  it 'should not allow a user currently in a battle to host a battle', (done) ->
    util.post '/secure/battle/host', {deck:deckId}, (err, res, body) ->
      should.not.exist(err)
      res.should.have.status(400)
      done()

  it 'should not allow a user currently in a battle to join a battle', (done) ->
    util.createDeck (err, deckId) ->
      should.not.exist(err)
      util.post "/secure/battle/#{battleId}/join", {deck:deckId}, (err, res, body) ->
        should.not.exist(err)
        res.should.have.status(400)
        done()

  it 'should not allow more than 2 people to join a battle', (done) ->
    util.loginAs 'battletest2', 'pass', (err, res, user) ->
      should.not.exist(err)
      util.createDeck (err, deckId) ->
        should.not.exist(err)
        postdata =
          deck:deckId
        util.post "/secure/battle/#{battleId}/join", postdata, (err, res, body) ->
          should.not.exist(err)
          res.should.have.status(400)
          done()

  # Setup server
  before (done) ->
    util.login (err, res, body) ->
      util.get '/secure/user', (err, res, body) ->
        user = JSON.parse(body)
        done()

  after (done) ->
    util.Users.model.remove {}, ->
      Battles.model.remove {}, ->
        done()
