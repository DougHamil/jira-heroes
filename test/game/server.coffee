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
        drawCards = (userId) ->
          (card) ->
            drawnCards[userId] = card
        for _, socket of sockets
          socket.on 'phase', onPhase
          socket.on 'opponent-turn', (active, fieldCards) ->
            activeUser = active
            should.exist(fieldCards)
          socket.on 'your-turn', (fieldCards) ->
            should.exist(fieldCards)
          socket.on 'draw-cards', drawCards(_)
        socketA.emit 'ready', (err) ->
          should.not.exist(err)

  activeSocket = null
  it 'should emit the first player\'s turn when all players are ready', (done) ->
    should.exist(activeUser)
    activeSocket = sockets[activeUser]
    should.exist(activeSocket)
    done()

  it 'should draw the first player\'s cards', (done) ->
    card = drawnCards[activeUser]
    should.exist(card)
    card.should.have.length(4)
    done()

  it 'should allow the first player to play a card', (done) ->
    activeSocket = sockets[activeUser]
    activeSocket.emit 'test', 'energy', 1000, ->
      activeSocket.emit 'play-card', drawnCards[activeUser][0]._id, (err, card)->
        should.not.exist(err)
        should.exist(card)
        done()

  getInactiveSocket = ->
    (socket for user, socket of sockets when user isnt activeUser)[0]

  it 'should not allow the inactive player to end the turn', (done) ->
    inactiveSocket = getInactiveSocket()
    inactiveSocket.emit 'end-turn', (err) ->
      should.exist(err)
      done()

  it 'should allow the active player to end the turn', (done) ->
    activeSocket = sockets[activeUser]
    activeSocket.emit 'end-turn', (err) ->
      should.not.exist(err)
      done()
