mongoose = require 'mongoose'
moment = require 'moment'

Schema = mongoose.Schema
ObjectId = Schema.ObjectId
_schema = new Schema
  name: String
  email: String
  activeBattles: [String]
  lastLoginTime: {type: Date, default: Date.now}
  library: [{type:String}] # All available cards
  decks: [{type:String}]
  battlesWon: {type:Number, default:0}
  battlesLost: {type:Number, default:0}
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
    lastLoginTime = moment().startOf('year')
    user = new _model {name:name, email:email, lastLoginTime: lastLoginTime}
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
      lastLoginTimeJira = jira.getDateTime(lastLoginTime)
      console.log " issues from #{lastLoginTimeJira}"
      jira.getTotalStoryPointsSince lastLoginTimeJira, username, password, (err, points) ->
        if err?
          cb err
        else
          user.wallet.storyPoints += points
          user.lastLoginWallet.storyPoints = points
          jira.getBugsCreatedSince lastLoginTimeJira, username, password, (err, points) ->
            if err?
              cb err
            else
              user.wallet.bugsReported += points
              user.lastLoginWallet.bugsReported = points
              jira.getBugsClosedSince lastLoginTimeJira, username, password, (err, points) ->
                if err?
                  cb err
                else
                  user.wallet.bugsClosed += points
                  user.lastLoginWallet.bugsClosed = points
                  user.lastLoginTime = currentTime
                  user.markModified('lastLoginTime')
                  user.save (err) ->
                    cb err, user

  _get = (id, cb) ->
    if id instanceof Array
      _model.find {_id:{$in:id}}, cb
    else
      _model.findOne {_id:id}, cb

  _getByName = (name, cb) ->
    _model.findOne {name:name}, cb

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
    getByName: _getByName

module.exports = User
