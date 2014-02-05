Events = require '../events'
math = require('mathjs')()

EXPLORATION_PARAM = math.sqrt(1)
TURN_LIMIT = 100
ITERATIONS = 20

class MCNode
  constructor: (@parent, @move, @battle) ->
    if @parent?
      @userId = @parent.userId
    @wins = 0
    @plays = 0
    @isTerminal = false
    @moves = null
    @moveId = 0
    @heuristic = 0
    @children = {}
    @isExpanded = false

    if @move?
      # Negative weight for end-turn (commonly will not help)
      if @move.event is Events.END_TURN
        @heuristic = -0.8

  pickBestMove: ->
    sorted = (child for moveId, child of @children)
    sorted.sort (a, b) -> b.plays - a.plays
    mostPlays = sorted[0].plays
    topScores = []
    for node in sorted
      if node.plays >= mostPlays
        topScores.push node
      else
        break
    debug = []
    for node in sorted
      debug.push {wins:node.wins, play:node.plays, move:node.move.debug}
    console.log "Moves:"
    console.log debug
    # Randomly pick for a tie
    return topScores[Math.floor(Math.random() * topScores.length)].move

  # Back propagate
  update: (wins, plays) ->
    @wins += wins
    @plays += plays
    if @parent?
      @parent.update(wins, plays)

  _calcUCT: (node)->
    h = node.heuristic
    p = node.plays
    w = node.wins
    if p is 0
      p = 1
    return (h/p) + (w / p) + (EXPLORATION_PARAM) * (math.sqrt((math.log(@plays,2)/p)))

  # Select a child node
  selectChild: ->
    if not @moves?
      return null
    else if @moves.length is 0
      return null
    else
      nodesWithWeight = []
      for moveId, node of @children
        uct = @_calcUCT(node)
        nodesWithWeight.push {node:node, weight:uct}
      nodesWithWeight.filter (w) -> not isNaN(w.weight)
      nodesWithWeight.sort (a, b) -> b.weight - a.weight
      return nodesWithWeight[0].node

  expand: (cb) ->
    @isExpanded = true
    if not @moves?
      @battle.getPossibleMoves (err, moves) =>
        if moves.length is 0
          @isTerminal = true
          cb null
        else
          todo = moves.length
          _runChild = (childBattle, move) =>
            return (err) =>
              if not err?
                @children[move.id] = new MCNode @, move, childBattle
              todo--
              if todo is 0
                cb null
          @moves = moves
          for move in moves
            move.id = @moveId++
            cBattle = @battle.clone()
            move.enact cBattle, _runChild(cBattle, move)
    else
      cb null

  playout: (cb) ->
    if @isTerminal
      #console.log "TERMINAL NODE PLAYOUT"
      cb null, @battle.model.winner.toString() is @userId.toString()
    else
      #console.log "STARTING PLAYOUT"
      battle = @battle.clone()
      battle.virtualPlayout TURN_LIMIT, (err, winner)=>
        #console.log "END PLAYOUT"
        cb null, winner? and winner.toString() is @userId.toString()


# Utilizes the Monte-Carlo Tree Search MCST algorithm for determining which move to make
class MonteCarloNaiveAI
  constructor:->

  calculateAction: (handler, battle, completeCb) ->
    iterCount = ITERATIONS
    if not @root?
      @root = new MCNode null, null, battle
      @root.userId = handler.player.userId
    root = @root
    _simulate = (node, cb) =>
      node.playout (err, isWin) =>
        if isWin
          node.update(1, 1)
        else
          node.update(0, 1)
        cb err

    _expand = (node, cb) =>
      node.expand (err) =>
        child = node.selectChild()
        if child?
          _simulate child, cb
        else
          _simulate node, cb

    _select = (node, cb) =>
      if not node.isExpanded
        _expand node, cb
      else
        child = node.selectChild()
        if child?
          _select child, cb
        else # terminal, simulate from parent
          _simulate node, cb

    _run = =>
      _select root, (err) =>
        iterCount--
        if iterCount is 0
          completeCb null, root.pickBestMove()
        else if iterCount > 0
          runAgain = => _run()
          setTimeout runAgain, 0

    root.expand (err) =>
      if root.moves.length is 1
        completeCb null, root.pickBestMove()
      else
        _run()

module.exports = MonteCarloNaiveAI
