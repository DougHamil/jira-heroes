mongoose = require 'mongoose'
Schema = mongoose.Schema
ObjectId = Schema.ObjectId
_schema = new Schema
  name: String
  email: String
  activeBattles: [String]
  lastLogin: String
  lastLoginPoints: {type:Number, default:0}
  lastLoginIssueKeys: [String]
  library: [{type:String}] # All available cards
  decks: [{type:String}]
  points: {type:Number, default:0}

_schema.methods.hasDeck = (deckId) ->
  return deckId in @decks

_schema.methods.ownsCards = (cardIds) ->
  for cardId in cardIds
    if cardId not in @library
      return false
  return true

User = (jira)->
  _model = mongoose.model('User', _schema)

  _create = (name, email, cb) ->
    user = new _model {name:name, email:email, lastLogin: jira.getDateTime()}
    user.decks = []
    user.save (err) ->
      cb err, user

  _login = (username, password, cb) ->
    jira.getUser username, password, (err, jiraUser) ->
      if err?
        cb err
      else
        _model.findOne {name:jiraUser.name}, (err, user) ->
          if err?
            cb err
          else if user?
            cb null, user
          else
            _create jiraUser.name, jiraUser.emailAddress, cb

  _updateStoryPoints = (username, password, user, cb) ->
    currentTime = jira.getDateTime()
    lastLogin = user.lastLogin ? currentTime
    lastLoginIssueKeys = user.lastLoginIssueKeys ? []
    jira.getTotalStoryPointsSince lastLogin, lastLoginIssueKeys, username, password, (err, points, keys) ->
      if err?
        cb err
      else
        user.points += points
        user.lastLoginPoints = points
        user.lastLoginIssueKeys = keys
        user.lastLogin = currentTime
        user.save (err) ->
          cb err, user

  _get = (id, cb) ->
    _model.findOne {_id:id}, cb

  _fromSession = (sessionUser, cb) ->
    _get sessionUser._id, cb

  ret =
    schema:_schema
    model:_model
    login:_login
    updateStoryPoints: _updateStoryPoints
    get:_get
    fromSession:_fromSession

module.exports = User
