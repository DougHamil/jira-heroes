server = require '../server'
should = require 'should'
mongoose = require 'mongoose'
http = require 'http'
request = require 'request'
util = require '../util'

# Mock secured endpoint
server.app.get '/secure/test', (req, res) ->
  res.send 200
server.app.get '/secure/user', (req, res) ->
  res.json req.session.user

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
  it 'should provide logout endpoint', (done) ->
    util.get '/user/logout', (err, res) ->
      res.statusCode.should.eql(302)
      done()
  it 'should not permit secure endpoint access after logging out', (done) ->
    util.get '/secure/test', (err, res) ->
      # Expect a redirect to login page
      res.statusCode.should.eql(302)
      done()
