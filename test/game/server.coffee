should = require 'should'
util = require '../util'
io = util.io

describe 'GameServer', ->

  it 'should automatically disconnect any users who are not logged-in', (done) ->
    socket = io.connect("http://localhost:#{util.port}", {'force new connection':true})
    socket.on 'disconnect', ->
      socket.disconnect()
      done()

  userA = null
  it 'should allow a logged-in user to connect', (done) ->
    util.login (err, res, user) ->
      userA = user._id
      socket = io.connect('http://localhost:'+util.port, {'force new connection': true})
      socket.on 'connected', ->
        socket.disconnect()
        done()

  battleId = null
  socketA = null
  sockets = {}
  it 'should not allow a user to join a battle that is not ready', (done) ->
    util.createDeck (err, deckId) ->
      should.not.exist(err)
      util.post '/secure/battle/host', {deck:deckId}, (err, res, body) ->
        battleId = JSON.parse(body)._id
        socketA = io.connect("http://localhost:#{util.port}", {'force new connection':true})
        socketA.on 'connected', ->
          socketA.emit 'join', battleId, (err) ->
            should.exist(err)
            done()
        sockets[userA] = socketA

  socketB = null
  userB = null
  it 'should allow a user to join a battle that is ready', (done) ->
    util.loginAs 'gametest', 'pass', (err, res, user) ->
      userB = user._id
      should.not.exist(err)
      util.createDeck (err, deckId) ->
        should.not.exist(err)
        util.post "/secure/battle/#{battleId}/join", {deck:deckId}, (err, res, body) ->
          should.not.exist(err)
          res.should.have.status(200)
          socketB = io.connect('http://localhost:'+util.port, {'force new connection': true})
          socketB.on 'connected', ->
            socketB.emit 'join', battleId, (err, data) ->
              should.not.exist(err)
              should.exist(data)
              done()
          sockets[userB] = socketB

  it 'should allow a player to ready-up', (done) ->
    socketB.emit 'ready', (err) ->
      should.not.exist(err)
      done()

  it 'should not allow a player to ready more than once', (done) ->
    socketB.emit 'ready', (err) ->
      should.exist(err)
      done()

  activeUser = null
  drawnCards = {}
  it 'should emit phase event when all players are ready', (done) ->
    util.login (err)->
      should.not.exist(err)
      socketA.emit 'join', battleId, (err) ->
        should.not.exist(err)
        checkins = 0
        onPhase = (oldPhase, newPhase) ->
          oldPhase.should.eql('initial')
          newPhase.should.eql('game')
          checkins++
          if checkins  == 2
            done()
        turn = (userId) ->
          (card) ->
            drawnCards[userId] = card
        for _, socket of sockets
          socket.on 'phase', onPhase
          socket.on 'opponent-turn', (active) ->
            activeUser = active
          socket.on 'your-turn', turn(_)
        socketA.emit 'ready', (err) ->
          should.not.exist(err)

  activeSocket = null
  it 'should emit the first player\'s turn when all players are ready', (done) ->
    should.exist(activeUser)
    activeSocket = sockets[activeUser]
    should.exist(activeSocket)
    done()

  it 'should draw the first player\'s card', (done) ->
    card = drawnCards[activeUser]
    should.exist(card)
    done()

