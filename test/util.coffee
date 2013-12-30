request = require 'request'
async = require 'async'
Cards = require '../lib/models/card'
Heroes = require '../lib/models/hero'

USERNAMES = []
PASSWORDS = []

exports.jar = request.jar()

exports.loadData = (cb) ->
  async.series [Cards.load, Heroes.load], (err) ->
    cb err

# Shim for auto-authenticate
exports.Jira =
  getUser: (u, p, cb)->
    if u in USERNAMES and p in PASSWORDS
      user =
        name: u
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
    jar:exports.jar
  return opts

exports.getOpts = (path) ->
  opts =
    url: getPath(path)
    method:'GET'
    followRedirect:false
    followAllRedirects:false
    jar:exports.jar
  return opts

exports.createDeck = (cb) ->
  exports.get '/hero', (err, res, body) ->
    hero = JSON.parse(body)[0]
    exports.post '/secure/deck', {hero:hero._id, name:'deck'}, (err, res, body) ->
      deck = JSON.parse(body)
      exports.post '/card/query', {query:JSON.stringify({cost:0})}, (err, res, body) ->
        cards = JSON.parse(body)[0..30]
        cards = cards.map (card) -> card._id
        while cards.length < 30
          cards.push cards[0]
        exports.post '/secure/deck/'+deck+'/cards', {cards:cards}, (err, res, body) ->
          cb err, deck

exports.loginAs = (username, pass, cb) ->
  USERNAMES.push username
  PASSWORDS.push pass
  postdata =
    username:username
    password:pass
  exports.post '/user/login', postdata, (err, res, body) ->
    exports.get '/secure/user', (err, res2, body) ->
      cb err, res, JSON.parse(body)

exports.login = (cb)->
  exports.loginAs 'testusername', 'testpassword', cb

# Patch in cookies from request into socket IO client
# https://gist.github.com/jfromaniello/4087861
originalRequest = require('xmlhttprequest').XMLHttpRequest
require('../node_modules/socket.io-client/node_modules/xmlhttprequest').XMLHttpRequest = ->
  originalRequest.apply @, arguments
  @setDisableHeaderCheck true
  stdOpen = @open
  @open = ->
    stdOpen.apply @, arguments
    header = exports.jar.store.idx.localhost['/']['connect.sid']
    @setRequestHeader 'cookie', header
  return

io = require 'socket.io-client'
exports.io = io
