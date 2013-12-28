Jira = require '../jira/api'
User = require '../models/user'
ModelHelper = require '../models/helper'

exports.getUserModel = (user, cb) ->
  User.findOne {_id:user._id}, (err, userModel) ->
    cb userModel

exports.get = (session) ->
  return session.user

exports.loggedIn = (session) ->
  return session.user?

calculateStoryPoints = (username, password, user, callback) ->
  currentTime = Jira.getDateTime()
  lastLogin = user.lastLogin ? currentTime
  lastLoginIssueKeys = user.lastLoginIssueKeys ? []
  Jira.getTotalStoryPointsSince lastLogin, lastLoginIssueKeys, username, password, (err, points, keys) ->
    if not err?
      user.points += points
      user.lastLoginPoints = points
      user.lastLoginIssueKeys = keys
      user.lastLogin = currentTime
      console.log "User #{user.name} has earned #{points} points since last logging on #{lastLogin}"
      callback err, user
    else
      callback err, null

exports.loginUser = (username, password, callback) ->
  Jira.getUser username, password, (err, jiraData) ->
    if not err?
      # Attempt to find the user by username
      User.findOne {name:jiraData.name}, (err, user) ->
        if not user?
          console.log "#{jiraData.name} is a new user, building new user from JIRA data..."
          if jiraData.name?
            user = new User({name: jiraData.name, email: jiraData.emailAddress, lastLogin:Jira.getDateTime()})
            calculateStoryPoints username, password, user, (err, user) ->
              if err?
                callback err, null
              else
                user.save (err) ->
                  callback err, user
        else
          callback err, user
    else
      callback err, null

exports.init = (app) ->
  app.post '/user/login', (req, res) ->
    username = req.body.username
    password = req.body.password
    exports.loginUser username, password, (err, user) ->
      if not err?
        req.session.user = user
        req.session.password = password
        redir = if req.session.redir? then req.session.redir else '/'
        delete req.session.redir
        res.redirect redir
      else
        req.session.loginFailed = true
        # Unable to login to JIRA, redirect to login
        res.redirect '/login'

  app.get '/user/logout', (req, res) ->
    req.session.user = null
    res.redirect '/'

  console.log 'Initialized user controller.'
