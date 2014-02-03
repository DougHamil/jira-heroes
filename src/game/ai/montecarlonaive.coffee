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

ITERATIONS = 500

# Utilizes the Monte-Carlo Tree Search MCST algorithm for determining which move to make
class MonteCarloNaiveAI
  constructor:->

  calculateAction: (handler, battle, cb) ->
    iterCount = ITERATIONS + 0
    moveId = 0

    # Initialize root node with the possible moves that the bot can make
    handler.getPossibleMoves (err, allMoves) =>
      #console.log "Possible moves:"
      #console.log allMoves
      root = new MCNode null, allMoves
      moveDistribution = {}
      for move in allMoves
        move.id = moveId++
        moveDistribution[move.id] = 0
      simulate = =>
        move = root.pickRandomMove()
        if move?
          @_playOutMove handler.getUserId(), move, battle, (err, success) =>
            moveDistribution[move.id] += success
            iterCount--
            if iterCount < 0
              cb null, @_pickBestMove(moveDistribution, allMoves)
            else
              setTimeout simulate, 0
        else
          cb null, @_pickBestMove(moveDistribution, allMoves)
      simulate()

  _pickBestMove: (moveDist, moves) ->
    moveValues = []
    for moveId, value of moveDist
      moveValues.push {moveId: parseInt(moveId), value:value}
    moveValues.sort (a, b) -> return a.value - b.value
    bestMove = moveValues[0]
    for move in moves
      if move.id is bestMove.moveId
        console.log bestMove.value
        return move
    return null

  _playOutMove: (userId, move, battle, cb) ->
    battle = battle.clone()
    # Invoke the move on the game state
    move.build battle, (err, actions) =>
      handler = battle.getActivePlayerHandler()
      handler.virtualTurnCount = 500
      battle.on 'virtual-game-over', (winner) =>
        healthDiff = handler.getHeroHandler().model.health - battle.getNonActivePlayerHandler().getHeroHandler().model.health
        console.log "WINNER #{healthDiff}"
        cb null, healthDiff
      handler.doVirtualTurn move


module.exports = MonteCarloNaiveAI
