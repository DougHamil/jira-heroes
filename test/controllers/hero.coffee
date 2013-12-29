should = require 'should'
util = require '../util'

describe 'HeroController', ->

  heroId = null
  it 'should return all hero metadata', (done) ->
    util.get '/hero', (err, res, body) ->
      should.not.exist(err)
      res.should.have.status(200)
      heroes = JSON.parse(body)
      heroes.should.be.instanceOf(Array)
      heroes[0].should.have.property('_id')
      heroId = heroes[0]._id
      done()

  it 'should return a specific hero\'s metadata', (done) ->
    util.get "/hero/#{heroId}", (err, res, body) ->
      should.not.exist(err)
      res.should.have.status(200)
      hero = JSON.parse(body)
      hero.should.have.property('_id', heroId)
      done()

