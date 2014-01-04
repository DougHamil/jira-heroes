{EventEmitter} = require 'events'

class GameTestHarness extends EventEmitter
  constructor: (socketsByUserId) ->
    @activeUser = null
    @sockets = socketsByUserId
    @users = (u for u, _ of @sockets)
    @expects = {}
    @drawnCards = {}
    for userId, socket of @sockets
      socket.on 'your-turn', @onYourTurn(userId)
      socket.on 'draw-card', @onDrawCard(userId)

  _listen: (user, event, cb) ->
    callback = (data...) =>
      expect = @expects[event]
      if expect?
        if (user in expect.users and not expect.done[user]?) or (user is @activeUser and 'active' in expect.users) or (user isnt @activeUser and 'inactive' in expect.users)
          expect.done[user] = data
          expect.doneCount++
          if expect.doneCount is expect.users.length
            console.log "[EVENT - #{event}] (#{user}): #{JSON.stringify(expect.done)}"
            delete @expects[event]
            cb callback
            expect.callback expect.done
    @sockets[user].on event, callback

  _listenAll: (event) ->
    removeListeners = (callback) =>
      for _, socket of @sockets
        socket.removeListener event, callback
    for userId in @users
      @_listen userId, event, removeListeners

  _listenOne: (user, event) ->
    removeListeners = (callback) =>
      @sockets[user].removeListener event, callback
    @_listen user, event, removeListeners

  expectActive: (event, cb) ->
    @expect 'active', event, cb
    @_listenAll event

  expectInactive: (event, cb) ->
    @expect 'inactive', event, cb
    @_listenAll event

  expect: (user, event, cb) ->
    @expects[event] =
      users: [user]
      callback: cb
      done: {}
      doneCount: 0
    if user isnt 'active' and user isnt 'inactive'
      @_listenOne user, event

  expectAll: (event, cb) ->
    @expects[event] =
      users: @users
      callback: cb
      done: {}
      doneCount: 0
    @_listenAll event

  emit: (users, action, data..., cb) ->
      if typeof users is 'string'
        @sockets[users].emit action, data...
      else
        for user in users
          @sockets[user].emit action, data...

  emitAll: (action, data..., cb) ->
    @emit @users, action, data..., cb

  emitActive: (action, data..., cb) ->
    @emit @activeUser, action, data..., cb

  emitAllButActive: (action, data..., cb) ->
    @emit (@users.filter (u) => u isnt @activeUser), action, data..., cb

  getInactiveUsers: ->
    return @users.filter (u) => u isnt @activeUser

  getRandomUser: ->
    return @users[Math.floor(@users.length * Math.random())]

  getOtherUser: (userId) ->
    return (@users.filter((u) -> u isnt userId))[0]

  getSocketForUser: (userId) ->
    return @sockets[userId]

  onYourTurn: (userId) ->
    =>
      @activeUser = userId

  onDrawCard: (userId) ->
    (cards) =>
      if not @drawnCards[userId]
        @drawnCards[userId] = []
      @drawnCards[userId] = @drawnCards[userId].concat cards

module.exports = GameTestHarness
