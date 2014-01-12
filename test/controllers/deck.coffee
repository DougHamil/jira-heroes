server = require '../server'
should = require 'should'
util = require '../util'

# Prepare server
deckController = require('../../lib/controllers/deck')(server.app, util.Users)

describe 'DeckController', ->
  it 'should return no decks for new user', (done) ->
    util.get '/secure/deck', (err, res, body) ->
      should.not.exist(err)
      decks = JSON.parse(body)
      should.exist(decks)
      decks.should.be.empty
      decks.should.be.an.instanceOf(Array)
      done()

  deckId = null
  it 'should allow user to create a new deck', (done) ->
    util.get '/hero', (err, res, body) ->
      should.not.exist(err)
      heroes = JSON.parse(body)
      util.post '/secure/deck', {hero:heroes[0]._id, name:'My New Deck'}, (err, res, body) ->
        res.should.have.status(200)
        deckId = JSON.parse(body)
        util.post '/secure/deck', {hero:heroes[0]._id, name:'My Other New Deck'}, (err, res, body) ->
          res.should.have.status(200)
          done()

  it 'should return any decks added', (done) ->
    util.get '/secure/deck', (err, res, body) ->
      should.not.exist(err)
      decks = JSON.parse(body)
      should.exist(decks)
      decks[0].name.should.eql('My New Deck')
      decks[1].name.should.eql('My Other New Deck')
      done()

  it 'should get a specific deck based on id', (done) ->
    util.get '/secure/deck/'+deckId, (err, res, body) ->
      should.not.exist(err)
      deck = JSON.parse(body)
      deck.should.have.property('name', 'My New Deck')
      done()

  # Database
  before (done) ->
    util.login (err, res, body)->
      done()
