request = require 'request'
async = require 'async'
Cards = require '../lib/models/card'
Heroes = require '../lib/models/hero'

exports.loadData = (cb) ->
  async.series [Cards.load, Heroes.load], (err) ->
    cb err

exports.Jira =
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

exports.port = 1337
getPath = (path) ->
  return "http://localhost:#{exports.port}#{path}"
exports.Users = require('../lib/models/user')(exports.Jira)

exports.get = (path, cb) ->
  request exports.getOpts(path), cb
exports.post = (path, data, cb) ->
  opts = exports.postOpts(path,data)
  request exports.postOpts(path, data), cb

exports.postOpts= (path, form) ->
  opts =
    url: getPath(path)
    method:'POST'
    form:form
    followRedirect:false
    followAllRedirects:false
    jar:true
  return opts

exports.getOpts = (path) ->
  opts =
    url: getPath(path)
    method:'GET'
    followRedirect:false
    followAllRedirects:false
    jar:true
  return opts

exports.login = (cb)->
  postdata =
    username:'testusername'
    password:'testpassword'
  exports.post '/user/login', postdata, cb
