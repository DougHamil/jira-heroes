should = require 'should'
Users = require('../util').Users

describe.skip "Users", ->
  afterEach (done) ->
    Users.model.remove {}, ->
      done()

  it 'logs in using Jira', (done) ->
    Users.login 'testusername', 'testpassword', (err, _user) ->
      should.exist(_user)
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
  it 'creates a model from user data stored in session', (done) ->
    Users.login 'testusername', 'testpassword', (err, user) ->
      user.save (err) ->
        should.not.exist(err)
        Users.fromSession {_id:user._id}, (err, userModel) ->
          userModel.should.have.property('hasDeck')
          userModel.should.have.property('save')
          done()
