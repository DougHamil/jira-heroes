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

  # Database
  before (done) ->
    mongoose.connect 'mongodb://localhost/jira_heroes_test'
    util.loadData (err)->
      util.login (err, res, body)->
        done()
  after (done) ->
    mongoose.disconnect()
    done()
