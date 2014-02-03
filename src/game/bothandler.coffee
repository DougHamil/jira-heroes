PlayerHandler = require './playerhandler'
AIFactory = require './ai/factory'
AIActions = require './ai/actions'
Errors = require './errors'
Events = require './events'
async = require 'async'


MAX_VIRTUAL_TURNS = 500

###
###
class BotHandler extends PlayerHandler
  constructor: (@battle, @player) ->
    super(@battle, @player)

  # Called by the battle when it's our turn to act
  doTurn: ->
    console.flag()
    console.log "DO TURN"
    virtualBattle = @battle.clone()
    AIFactory.getAI(@player.botType).calculateAction @, virtualBattle, (err, aiAction) =>
      console.log "AI Hand Cards:"
      console.log @getHandCards().length
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
  doVirtualTurn: (seedMove)->
    #console.log "Virtual turn for #{@player.userId} #{@virtualTurnCount}"
    if @virtualTurnCount?
      @virtualTurnCount--
    doMove = (move) =>
      move.build @battle, (err, actions) =>
        payloads = @battle.processActions(actions)
        @emit move.event, payloads
        if @battle.getPhase() isnt 'game'
          @battle.emit 'virtual-game-over', @battle.model.winner
        else if move.event isnt Events.END_TURN and @isActive() and @battle.getPhase() is 'game'
          doNextTurn = => @doVirtualTurn()
          setTimeout doNextTurn, 0
    if seedMove?
      doMove(seedMove)
    else
      if not @virtualTurnCount? or @virtualTurnCount > 0
        #console.log "PLAYED"
        @getPossibleMoves (err, moves) =>
          # Pick random move
          doMove moves[Math.floor(Math.random() * moves.length)]
      else
        #console.log "NOT PLAYED"
        @battle.emit 'virtual-game-over', @battle.model.winner

  _doATurn: (move) ->

module.exports = BotHandler
