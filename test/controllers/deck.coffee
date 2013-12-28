server = require '../server'
should = require 'should'
mongoose = require 'mongoose'
util = require '../util'

# Prepare server
userController = require('../../lib/controllers/user')(server.app, util.Users)
deckController = require('../../lib/controllers/deck')(server.app, util.Users)
server.app.listen(util.port)

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
  it 'should allow user to post a new deck', (done) ->
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
      decks.should.have.length(2)
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
    mongoose.connect 'mongodb://localhost/jira_heroes_test'
    util.login (err, res, body)->
      done()
  after (done) ->
    mongoose.disconnect()
    done()
