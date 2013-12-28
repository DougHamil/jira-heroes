server = require('../server')
http = require 'http'
port = 1337
sessionCookie = null

defaultPostOptions = (path) ->
  opts =
    host: 'localhost'
    port: port
    path:path
    method: 'POST'
    headers:
      Cookie: sessionCookie
defaultGetOptions = (path) ->
  opts =
    host: 'localhost'
    port: port
    path:path
    method: 'GET'
    headers:
      Cookie: sessionCookie

testUser =
  name:'testusername'

mockUserModel =
  login: (u, p, cb) ->
    cb null, testUser
  updateStoryPoints: (u, p, user, cb) ->
    user.points = 100
    cb null, user

userController = require('../../lib/controllers/user')(server.app, mockUserModel)

# Mock secured endpoint
server.app.get '/secure/test', (req, res) ->
  res.send 200
server.app.get '/secure/user/points', (req, res) ->
  res.json req.session.user

server.app.listen(port)

describe 'UserController', ->
  it 'should provide login endpoint', (done) ->
    postdata = JSON.stringify
      username:'testusername'
      password:'testpassword'
    req = http.request defaultPostOptions('/user/login'), (res) ->
      sessionCookie = res.headers['set-cookie'][0]
      res.statusCode.should.eql(302)
      done()
    req.write postdata
    req.end()
  it 'should permit secure endpoint access after logging in', (done) ->
    req = http.request defaultGetOptions('/secure/user/points'), (res) ->
      res.statusCode.should.eql(200)
      res.on 'data', (chunk) ->
        user = JSON.parse(new String(chunk))
        user.points.should.eql(100)
        done()
    req.end()
  it 'should provide logout endpoint', (done) ->
    req = http.request defaultGetOptions('/user/logout'), (res) ->
      res.statusCode.should.eql(302)
      done()
    req.end()
  it 'should not permit secure endpoint access after logging out', (done) ->
    req = http.request defaultGetOptions('/secure/test'), (res) ->
      # Expect a redirect to login page
      res.statusCode.should.eql(302)
      done()
    req.end()
