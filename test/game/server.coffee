should = require 'should'
util = require '../util'
io = util.io

describe 'GameServer', ->

  it 'should automatically disconnect any users who are not logged-in', (done) ->
    socket = io.connect("http://localhost:#{util.port}", {'force new connection':true})
    socket.on 'disconnect', ->
      socket.disconnect()
      done()

  it 'should allow a logged-in user to connect', (done) ->
    util.login (err, res, user)->
      util.get '/secure/deck', (err, res, body) ->
        socket = io.connect('http://localhost:'+util.port, {'force new connection': true})
        socket.on 'connected', ->
          socket.disconnect()
          done()

  it 'should allow a connected user to join a battle', (done) ->
    util.createDeck (err, deckId) ->
      should.not.exist(err)
      util.post '/secure/battle/host', {deck:deckId}, (err, res, body) ->
        should.not.exist(err)
        battle = JSON.parse(body)
        socket = io.connect('http://localhost:'+util.port, {'force new connection': true})
        socket.on 'connected', ->
          socket.emit 'join', battle._id, (err, data) ->
            should.not.exist(err)
            should.exist(data)
            done()
