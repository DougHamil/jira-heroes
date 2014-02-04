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
    AIFactory.getAI(@player.botType).calculateAction @, virtualBattle, (err, aiAction) =>
      #console.log "AI Hand Cards:"
      #console.log @getHandCards().length
      console.flag()
      console.log "AI Picked:"
      console.log aiAction
      if aiAction?
        aiAction.build @battle, (err, actions) =>
          @emit aiAction.event, @battle.processActions(actions)
          if aiAction.event isnt Events.END_TURN and @isActive() and @battle.getPhase() is 'game'
            @doTurn()
      else
        console.log "ERROR: Bot unable to determine a valid move"

  # Called by a virtual battle when it's our turn to act
  doVirtualTurn: ->
    #console.log "Virtual turn for #{@player.userId} #{@virtualTurnCount}"
    if @virtualTurnCount?
      @virtualTurnCount--
    if not @virtualTurnCount? or @virtualTurnCount > 0
      #console.log "PLAYED"
      @getPossibleMoves (err, moves) =>
        move = null
        if moves.length is 1 and @getDeckCards().length > 0 and @getFieldCards().length > 0 and @getHandCards().length > 0
          move = moves[0]
        else if moves.length > 1
          #moves = moves.filter (m) -> m.event isnt Events.END_TURN
          move = moves[Math.floor(Math.random() * moves.length)]
        if move?
          move.enact @battle, (err) =>
            if move.event isnt Events.END_TURN
              doNextTurn = => @doVirtualTurn()
              setTimeout doNextTurn, 0
        else
          #console.log "Virtual game over out of moves"
          @battle.emit 'virtual-game-over', @battle.model.winner
    else
      #console.log "Virtual game timeout"
      @battle.emit 'virtual-game-over', @battle.model.winner

  _doATurn: (move) ->

module.exports = BotHandler
