Events = require '../events'
class MCNode
  constructor: (@parent, moves) ->
    if @parent?
      @parent.children.push @
    @children = []
    @untried = moves.filter (m) -> return true
    @tried = []

  pickRandomMove: ->
    if @untried.length > 0
      move = @untried[Math.floor(Math.random() * @untried.length)]
      @untried = @untried.filter (m) -> m isnt move
      return move
    return null

ITERATIONS = 50

# Utilizes the Monte-Carlo Tree Search MCST algorithm for determining which move to make
class MonteCarloNaiveAI
  constructor:->

  calculateAction: (handler, battle, cb) ->
    iterCount = ITERATIONS + 0

    # Initialize root node with the possible moves that the bot can make
    handler.getPossibleMoves (err, allMoves) =>
      console.log "Possible moves:"
      console.log allMoves
      root = new MCNode null, allMoves
      simulate = =>
        move = root.pickRandomMove()
        if move?
          @_playOutMove handler.getUserId(), move, battle, (err, success) =>
            if success
              cb null, move
            else
              iterCount--
              if iterCount < 0
                cb null, allMoves[Math.floor(Math.random() * allMoves.length)]
              else
                setTimeout simulate, 0
        else
          cb null, allMoves[Math.floor(Math.random() * allMoves.length)]
      simulate()

  _playOutMove: (userId, move, battle, cb) ->
    battle = battle.clone()
    # Invoke the move on the game state
    move.build battle, (err, actions) =>
      handler = battle.getActivePlayerHandler()
      handler.virtualTurnCount = 100
      battle.on 'virtual-game-over', (winner) =>
        console.log "WINNER #{winner}"
        cb null, winner is userId
      handler.doVirtualTurn move


module.exports = MonteCarloNaiveAI
