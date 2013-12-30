Errors = require './errors'
BattleManager = require './battlemanager'

###
ConnectionManager handles initial socket connections by routing battle hosting and joining
to the proper Battle instance
###
class UserManager
  constructor: (@user, @socket) ->
    @socket.on 'join', (battleId, cb) =>
      @onConnect(battleId, cb)

  ###
  # Called when a user wants to connect to a battle
  ###
  onConnect: (battleId, cb) ->
    if @battle?
      # User is already in a battle
      cb Errors.ALREADY_IN_BATTLE
    else if battleId isnt @user.activeBattle
      # The user is not joined in this battle
      cb Errors.INVALID_BATTLE
    else
      BattleManager.get battleId, (err, @battle) =>
        if err?
          cb err
        else
          @battle.onConnect @user, @socket
          cb null, @battle.getData(@user)

module.exports = UserManager
