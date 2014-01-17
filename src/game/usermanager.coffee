Errors = require './errors'
BattleManager = require './battlemanager'

###
ConnectionManager handles initial socket connections by routing battle hosting and joining
to the proper Battle instance
###
class UserManager
  constructor: (@user, @socket) ->
    @socket.on 'join', (battleId, cb) => @onJoin(battleId, cb)
    @socket.on 'battle-status', (battleId, cb) => @onBattleStatus battleId, cb

  onBattleStatus: (battleId, cb) ->
    BattleManager.get battleId, (err, battle) =>
      cb err

  ###
  # Called when the socket was disconnected
  ###
  onDisconnected: ->
    if @battle?
      @battle.onDisconnect @user
  ###
  # Called when a user wants to join a battle
  ###
  onJoin: (battleId, cb) ->
    if @battle?
      # User is already in a battle
      cb Errors.ALREADY_IN_BATTLE
    else if battleId not in @user.activeBattles
      # The user is not joined in this battle
      cb Errors.INVALID_BATTLE
    else
      BattleManager.get battleId, (err, battle) =>
        if err?
          cb err
        else
          @battle = battle
          @battle.onConnect @user, @socket
          cb null, @battle.getData(@user)

module.exports = UserManager
