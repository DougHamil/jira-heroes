server = require '../server'
should = require 'should'
mongoose = require 'mongoose'
http = require 'http'
request = require 'request'
port = 1337
sessionCookie = null

getPath = (path) ->
  return "http://localhost:#{port}#{path}"

post = (path, form) ->
  opts =
    url: getPath(path)
    method:'POST'
    form:form
    followRedirect:false
    followAllRedirects:false
  if sessionCookie?
    opts.headers =
      Cookie: sessionCookie
  return opts
get = (path) ->
  opts =
    url: getPath(path)
    method:'GET'
    followRedirect:false
    followAllRedirects:false
  if sessionCookie?
    opts.headers =
      Cookie: sessionCookie
  return opts


testUser =
  name:'testusername'

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
    cb null, 100, []

Users = require('../../lib/models/user')(mockJiraApi)

userController = require('../../lib/controllers/user')(server.app, Users)

# Mock secured endpoint
server.app.get '/secure/test', (req, res) ->
  res.send 200
server.app.get '/secure/user/deck/add', (req, res) ->
  Users.fromSession req.session.user, (err, user) ->
    should.exist(user)
    should.not.exist(err)
    user.decks.push 'ABC'
    user.save (err) ->
      should.not.exist(err)
      req.session.user = user
      res.send 200
server.app.get '/secure/user', (req, res) ->
  res.json req.session.user

server.app.listen(port)

describe 'UserController', ->
  before (done) ->
    mongoose.connect 'mongodb://localhost/jira_heroes_test'
    done()

  after (done) ->
    mongoose.disconnect()
    done()

  it 'should provide login endpoint', (done) ->
    postdata =
      username:'testusername'
      password:'testpassword'
    request post('/user/login', postdata), (err, res, body) ->
      sessionCookie = res.headers['set-cookie'][0]
      res.statusCode.should.eql(302)
      res.headers.location.should.eql('/')
      done()
  it 'should use the user model to store data', (done) ->
    request get('/secure/user/deck/add'), (err, res) ->
      res.statusCode.should.eql(200)
      request get('/secure/user'), (err, res, body) ->
        user = JSON.parse(body)
        user.decks.should.include 'ABC'
        done()
  it 'should provide logout endpoint', (done) ->
    request get('/user/logout'), (err, res) ->
      res.statusCode.should.eql(302)
      done()
  it 'should not permit secure endpoint access after logging out', (done) ->
    request get('/secure/test'), (err, res) ->
      # Expect a redirect to login page
      res.statusCode.should.eql(302)
      done()
