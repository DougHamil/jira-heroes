server = require '../server'
should = require 'should'
mongoose = require 'mongoose'
http = require 'http'
request = require 'request'
util = require '../util'
userController = require('../../lib/controllers/user')(server.app, util.Users)

# Mock secured endpoint
server.app.get '/secure/test', (req, res) ->
  res.send 200
server.app.get '/secure/user/deck/add', (req, res) ->
  util.Users.fromSession req.session.user, (err, user) ->
    should.exist(user)
    should.not.exist(err)
    user.decks.push 'ABC'
    user.save (err) ->
      should.not.exist(err)
      req.session.user = user
      res.send 200
server.app.get '/secure/user', (req, res) ->
  res.json req.session.user

server.app.listen(util.port)

describe 'UserController', ->
  before (done) ->
    mongoose.connect 'mongodb://localhost/jira_heroes_test'
    done()

  after (done) ->
    mongoose.disconnect()
    done()

  it 'should provide login endpoint', (done) ->
    util.login (err, res, body) ->
      res.statusCode.should.eql(302)
      res.headers.location.should.eql('/')
      done()
  it 'should use the user model to store data', (done) ->
    util.get '/secure/user/deck/add', (err, res) ->
      res.statusCode.should.eql(200)
      util.get '/secure/user', (err, res, body) ->
        user = JSON.parse(body)
        user.decks.should.include 'ABC'
        done()
  it 'should provide logout endpoint', (done) ->
    util.get '/user/logout', (err, res) ->
      res.statusCode.should.eql(302)
      done()
  it 'should not permit secure endpoint access after logging out', (done) ->
    util.get '/secure/test', (err, res) ->
      # Expect a redirect to login page
      res.statusCode.should.eql(302)
      done()
