Decks = require '../models/deck'
Battles = require '../models/battle'
async = require 'async'


ADD_BOT = false

module.exports = (app, Users) ->

  userJoinBattle = (addBotFlag, battle, user, deckId, res) ->
    if battle.users.length >= 2
      res.send 400, 'Battle full'
    else if deckId not in user.decks
      res.send 400, "Invalid deck #{deckId}"
    else if user._id in battle.users
      res.send 400, 'Already in battle'
    else
      battle.users.push user._id
      user.activeBattles.push battle._id
      Decks.get deckId, (err, deck) ->
        if err?
          res.send 500, err
        else
          addPlayer = =>
            battle.addPlayer user._id, deck, (err, player) ->
              if err?
                res.send 500, err
              else
                async.series [battle.save.bind(battle), user.save.bind(user)], (err) ->
                  if err?
                    res.send 500, err
                  else
                    res.json battle.getPublicData()
          if addBotFlag
            battle.users.push user._id + 'BOT'
            battle.addBot 'montecarlonaive', user._id + "BOT", deck, (err, bot) ->
              addPlayer()
          else
            addPlayer()

  # TEMP: More easily drop all existing battles without having to wipe the user database too
  #app.get '/secure/battle/dropall', (req, res) ->
  #  if req.session.user.name is 'dhamilton'
  #    Battles.find

  # Join battle
  app.post '/secure/battle/:id/join', (req, res) ->
    battleId = req.params.id
    deckId = req.body.deck
    Battles.get battleId, (err, battle) ->
      if err?
        res.send 500, err
      else if not battle?
        res.send 400, "Invalid battle ID #{battleId}"
      else
        Users.fromSession req.session.user, (err, user) ->
          if err?
            res.send 500, err
          else
            userJoinBattle false, battle, user, deckId, res

  # Host battle
  app.post '/secure/battle/host', (req, res) ->
    deckId = req.body.deck
    addBot = req.body.bot? and req.body.bot
    addBot = addBot? and addBot is 'true'
    Users.fromSession req.session.user, (err, user) ->
      if err?
        res.send 500, err
      else
        Battles.create (err, battle) ->
          if err?
            res.send 500, err
          else
            userJoinBattle addBot, battle, user, deckId, res

  # Query battle
  app.post '/battle/query', (req, res) ->
    query = req.body.query
    if not query?
      res.send 400, "Expected 'query'"
    else
      query = JSON.parse(query)
      Battles.query query, (err, battles) ->
        if err?
          res.send 500, err
        else
          battles = battles.map (b) -> b.getPublicData()
          res.json battles

  # Get active battles
  app.get '/secure/battle/active', (req, res) ->
    Users.fromSession req.session.user, (err, user) ->
      if err?
        res.send 500, err
      else
        if not user.activeBattles?
          res.json null
        else
          Battles.get user.activeBattles, (err, battles) ->
            if err?
              res.send 500, err
            else
              battles = battles.map (b) -> b.getPublicData()
              res.json battles

  # Get all active battles
  app.get '/battle', (req, res) ->
    Battles.getAll (err, battles) ->
      if err?
        res.send 500, err
      else
        battles = battles.map (b) -> b.getPublicData()
        res.json battles

  # Get all open battles
  app.get '/battle/open', (req, res) ->
    Battles.query {'users.1':{$exists:false}}, (err, battles) ->
      if err?
        res.send 500, err
      else
        battles = battles.map (b) -> b.getPublicData()
        res.json battles

  # Get specific battle
  app.get '/battle/:id', (req, res) ->
    id = req.params.id
    Battles.get id, (err, battle) ->
      if err?
        res.send 500, err
      else if battle?
        if battle instanceof Array
          battle = battle[0]
        res.json battle.getPublicData()
      else
        res.send 400, "Bad battle id #{id}"
