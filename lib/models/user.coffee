mongoose = require 'mongoose'
moment = require 'moment'
Schema = mongoose.Schema
ObjectId = Schema.ObjectId
_schema = new Schema
  name: String
  email: String
  activeBattles: [String]
  lastLoginTime: {type: Date, default: Date.now}
  lastLoginTimeJira: String
  lastLoginIssueKeys: [String]
  library: [{type:String}] # All available cards
  decks: [{type:String}]
  lastLoginWallet:
    storyPoints: {type:Number, default:0}
    bugsClosed: {type:Number, default:0}
    bugsReported: {type:Number, default:0}
  wallet:
    storyPoints: {type:Number, default:0}
    bugsClosed: {type:Number, default:0}
    bugsReported: {type:Number, default:0}

_schema.methods.getPublicData = ->
  out =
    _id:@_id
    name: @name
_schema.methods.hasDeck = (deckId) ->
  return deckId in @decks

_schema.methods.ownsCards = (cardIds) ->
  for cardId in cardIds
    if cardId not in @library
      return false
  return true

_schema.methods.canAfford = (cardCost) ->
  if cardCost.storyPoints? and @wallet.storyPoints < cardCost.storyPoints
    return false
  if cardCost.bugsClosed? and @wallet.bugsClosed < cardCost.bugsClosed
    return false
  if cardCost.bugsReported? and @wallet.bugsReported < cardCost.bugsReported
    return false
  return true

_schema.methods.deduct = (cardCost) ->
  @wallet.storyPoints -= cardCost.storyPoints if cardCost.storyPoints?
  @wallet.bugsClosed -= cardCost.bugsClosed if cardCost.bugsClosed?
  @wallet.bugsReported -= cardCost.bugsReported if cardCost.bugsReported?

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

  _updateWallet = (username, password, user, cb) ->
    lastLoginTime = moment(user.lastLoginTime)
    currentTime = moment()
    # Do nothing if the last login was less than a minute ago
    if currentTime.diff(lastLoginTime, 'minutes') <= 1
      cb null, user
    else
      currentTime = moment()
      currentTimeJira = jira.getDateTime()
      lastLoginTimeJira = user.lastLoginTimeJira || currentTimeJira
      lastLoginIssueKeys = user.lastLoginIssueKeys || []
      foundIssueKeys = []
      jira.getTotalStoryPointsSince lastLoginTimeJira, lastLoginIssueKeys, username, password, (err, points, keys) ->
        if err?
          cb err
        else
          user.wallet.storyPoints += points
          user.lastLoginWallet.storyPoints = points
          foundIssueKeys = foundIssueKeys.concat(keys)
          jira.getBugsCreatedSince lastLoginTimeJira, lastLoginIssueKeys, username, password, (err, points, keys) ->
            if err?
              cb err
            else
              user.wallet.bugsReported += points
              user.lastLoginWallet.bugsReported = points
              foundIssueKeys = foundIssueKeys.concat(keys)
              jira.getBugsClosedSince lastLoginTimeJira, lastLoginIssueKeys, username, password, (err, points, keys) ->
                if err?
                  cb err
                else
                  user.wallet.bugsClosed += points
                  user.lastLoginWallet.bugsClosed = points
                  foundIssueKeys = foundIssueKeys.concat(keys)
                  user.lastLoginIssueKeys = foundIssueKeys
                  user.lastLoginTime = currentTime
                  user.lastLoginTimeJira = currentTimeJira
                  user.markModified('lastLoginTime')
                  user.save (err) ->
                    cb err, user

  _get = (id, cb) ->
    if id instanceof Array
      _model.find {_id:{$in:id}}, cb
    else
      _model.findOne {_id:id}, cb

  _getOrCreate = (name, email, cb) ->
    _model.findOne {name:name}, (err, user) ->
      if err? or not user?
        _create name, email, cb
      else
        cb null, user


  _fromSession = (sessionUser, cb) ->
    _get sessionUser._id, cb

  ret =
    getOrCreate:_getOrCreate
    schema:_schema
    model:_model
    login:_login
    updateWallet: _updateWallet
    get:_get
    fromSession:_fromSession

module.exports = User
