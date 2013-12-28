should = require 'should'
mongoose = require 'mongoose'

mockJiraApi =
  getUser: (u, p, cb)->
    if u is 'testusername' and p is 'testpassword'
      user =
        name: 'testusername'
        emailAddress:'test@test.com'
      cb null, user
    else
      cb true
  getDateTime: ->
    return '01/01/2000 00:00:00'
  getTotalStoryPointsSince: (l, ll, u, p, cb) ->
    cb null, 1, []

mongoose.connect 'mongodb://localhost/jira_heroes_test'

Users = require('../../lib/models/user')(mockJiraApi)

describe "Users", ->

  afterEach (done) ->
    Users.model.remove {}, ->
      done()

  it 'logs in using Jira', (done) ->
    Users.login 'testusername', 'testpassword', (err, user) ->
      should.exist(user)
      should.not.exist(err)
      done()
  it 'gets story points since last login using Jira', (done) ->
    Users.login 'testusername', 'testpassword', (err, user) ->
      Users.updateStoryPoints 'testusername', 'testpassword', user, (err, user) ->
        user.should.have.property('lastLoginPoints', 1)
        user.should.have.property('points', 1)
        done()
  it 'creates a saveable model', (done) ->
    Users.login 'testusername', 'testpassword', (err, user) ->
      should.exist(user)
      user.save (err) ->
        should.not.exist(err)
        done()
  it 'provides a hasDeck method', (done) ->
    Users.login 'testusername', 'testpassword', (err, user) ->
      should.exist(user)
      user.should.have.property('hasDeck')
      user.hasDeck('0').should.be.false
      user.decks.push '0'
      user.hasDeck('0').should.be.true
      done()

