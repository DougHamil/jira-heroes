server = require '../server'
should = require 'should'
mongoose = require 'mongoose'
util = require '../util'

describe 'CardController', ->
  cardController = require('../../lib/controllers/card')(server.app, util.Users)

  cardId = null
  it 'should return all available cards', (done) ->
    util.get '/card', (err, res, body) ->
      should.not.exist(err)
      cards = JSON.parse(body)
      cards.should.be.instanceOf(Array)
      cardId = cards[0]._id
      done()

  it 'should get a specific card by ID', (done) ->
    util.get "/card/#{cardId}", (err, res, body) ->
      should.not.exist(err)
      card = JSON.parse(body)
      card.should.be.type('object')
      res.should.have.status(200)
      done()

  it 'should get cards by querying', (done) ->
    util.post "/card/query", {query:JSON.stringify({name:'testcard'})}, (err, res, body) ->
      should.not.exist(err)
      card = JSON.parse(body)
      card.should.be.instanceOf(Array)
      card.should.have.length(1)
      card = card[0]
      card.should.be.type('object')
      card.should.have.property('name', 'testcard')
      res.should.have.status(200)
      cardId = card._id
      done()

  it 'should allow the user to add a card to his library', (done) ->
    util.post '/secure/user/library', {card:cardId}, (err, res, body) ->
      should.not.exist(err)
      res.should.have.status(200)
      done()

  it 'should return the user\'s card library', (done) ->
    util.get "/secure/user/library", (err, res, body) ->
      should.not.exist(err)
      cards = JSON.parse(body)
      cards.should.be.instanceOf(Array)
      cards.should.have.length(1)
      cards[0].should.have.property('_id', cardId)
      cards[0].should.have.property('name', 'testcard')
      res.should.have.status(200)
      done()

  # Database
  before (done) ->
    mongoose.connect 'mongodb://localhost/jira_heroes_test'
    require('../../lib/models/card').load (err) ->
      util.login (err, res, body)->
        done()
  after (done) ->
    mongoose.disconnect()
    done()
