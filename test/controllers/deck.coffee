server = require '../server'
should = require 'should'
mongoose = require 'mongoose'
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
    util.post '/secure/deck', {hero:'hacker',name:'My New Deck'}, (err, res, body) ->
      res.should.have.status(200)
      deckId = JSON.parse(body)
      util.post '/secure/deck', {hero:'hacker',name:'My Other New Deck'}, (err, res, body) ->
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

  it 'should allow setting the deck\'s cards', (done) ->
    postdata =
      cards:['test', 'test2']
    util.post "/secure/deck/#{deckId}/cards", postdata, (err, res, body) ->
      should.not.exist(err)
      res.should.have.status(200)
      body.should.equal(deckId)
      done()

  it 'should return newly added cards', (done) ->
    util.get "/secure/deck/#{deckId}", (err, res, body) ->
      should.not.exist(err)
      deck = JSON.parse(body)
      deck.cards.should.have.length(2)
      deck.cards[0].should.eql('test')
      done()

  # Database
  before (done) ->
    mongoose.connect 'mongodb://localhost/jira_heroes_test'
    util.login (err, res, body)->
      done()
  after (done) ->
    mongoose.disconnect()
    done()
