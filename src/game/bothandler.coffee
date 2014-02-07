PlayerHandler = require './playerhandler'
AIFactory = require './ai/factory'
AIActions = require './ai/actions'
Errors = require './errors'
Events = require './events'
async = require 'async'


###
###
class BotHandler extends PlayerHandler
  constructor: (@battle, @player) ->
    super(@battle, @player)

  # Called by the battle when it's our turn to act
  doTurn: ->
    virtualBattle = @battle.clone()
    otherPlayer = @battle.getNonActivePlayerHandler()
    player = @battle.getActivePlayerHandler()
    #console.log "#{otherPlayer.player.userId}: #{otherPlayer.getHeroHandler().model.health}"
    #console.log "#{player.player.userId}: #{player.getHeroHandler().model.health}"
    #console.log player.getFieldCards()
    AIFactory.getAI(@player.botType).calculateAction @, virtualBattle, (err, aiAction) =>
      #console.log "AI Hand Cards:"
      #console.log @getHandCards().length
      #console.flag()
      #console.log "AI Picked:"
      #console.log aiAction
      if aiAction?
        aiAction.build @battle, (err, actions) =>
          @emit aiAction.event, @battle.processActions(actions)
          if aiAction.event isnt Events.END_TURN and @isActive() and @battle.getPhase() is 'game'
            @doTurn()
      else
        console.log "ERROR: Bot unable to determine a valid move"

  # Called by a virtual battle when it's our turn to act
  doVirtualTurn: (cb) ->
    @getPossibleMoves (err, moves) =>
      move = null
      if moves.length is 1
        move = moves[0]
      else if moves.length > 1
        #moves = moves.filter (m) -> m.event isnt Events.END_TURN
        move = moves[Math.floor(Math.random() * moves.length)]
      if move?
        move.enact @battle, cb
      else
        cb null
module.exports = BotHandler
