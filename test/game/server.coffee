should = require 'should'
util = require '../util'
GameTestHarness = require './harness'
GameFlowTest = require './flow'
io = util.io

describe.skip 'GameServer', ->

  it 'should automatically disconnect any users who are not logged-in', (done) ->
    socket = io.connect("http://localhost:#{util.port}", {'force new connection':true})
    socket.on 'disconnect', ->
      socket.disconnect()
      done()

  userA = null
  userB = null
  it 'should allow a logged-in user to connect', (done) ->
    util.login (err, res, user) ->
      userA = user._id
      socket = io.connect('http://localhost:'+util.port, {'force new connection': true})
      socket.on 'connected', ->
        socket.disconnect()
        done()

  battleId = null
  sockets = {}
  it 'should not allow a user to join a battle that is not ready', (done) ->
    util.createDeck (err, deckId) ->
      should.not.exist(err)
      util.post '/secure/battle/host', {deck:deckId}, (err, res, body) ->
        battleId = JSON.parse(body)._id
        socket = io.connect("http://localhost:#{util.port}", {'force new connection':true})
        socket.on 'connected', ->
          socket.emit 'join', battleId, (err) ->
            should.exist(err)
            done()
        sockets[userA] = socket

  harness = null
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
          harness = new GameTestHarness sockets
          userA = userB
          userB = harness.getOtherUser userA

  it 'should allow a player to ready-up', (done) ->
    socket = harness.getSocketForUser userA
    socket.emit 'ready', (err) ->
      should.not.exist(err)
      done()

  it 'should not allow a player to ready more than once', (done) ->
    socket = harness.getSocketForUser userA
    socket.emit 'ready', (err) ->
      should.exist(err)
      done()

  it 'should emit phase event when all players are ready', (done) ->
    harness.expectActive 'your-turn', (data) ->
      data = data[harness.activeUser]
      fieldCards = data[0]
      #should.exist(fieldCards)
    harness.expectInactive 'opponent-turn', (data) ->
      for user in harness.getInactiveUsers()
        userData = data[user]
        if userData?
          should.exist(userData[0])
    harness.expectAll 'phase', (data) ->
      for user, datum of data
        oldPhase = datum[0]
        newPhase = datum[1]
        oldPhase.should.eql('initial')
        newPhase.should.eql('game')
      done()
    harness.expectAll 'draw-card', (data) ->
      for user, datum of data
        cards = datum[0]
        should.exist(cards)
    userB = harness.getOtherUser userA
    socket = harness.getSocketForUser userB
    socket.emit 'join', battleId, (err) ->
      should.not.exist(err)
      socket.emit 'ready', (err) ->
        should.not.exist(err)

  it 'should draw the first player\'s cards', (done) ->
    cards = harness.drawnCards[harness.activeUser]
    should.exist(cards)
    cards.should.have.length(4)
    done()
    GameFlowTest.run harness

