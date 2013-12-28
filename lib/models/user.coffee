mongoose = require 'mongoose'
Schema = mongoose.Schema
ObjectId = Schema.ObjectId
_schema = new Schema
  name: String
  email: String
  lastLogin: String
  lastLoginPoints: {type:Number, default:0}
  lastLoginIssueKeys: [String]
  decks: [{type:String}]
  points: {type:Number, default:0}
_schema.methods.hasDeck = (deckId) ->
  return deckId in @decks

User = (jira)->

  _model = mongoose.model('User', _schema)

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
            user = new _model {name:jiraUser.name, email:jiraUser.emailAddress, lastLogin:jira.getDateTime()}
            cb null, user

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

  ret =
    schema:_schema
    model:_model
    login:_login
    updateStoryPoints: _updateStoryPoints

module.exports = User
