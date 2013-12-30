Decks = require '../models/deck'
Battles = require '../models/battle'
async = require 'async'

module.exports = (app, Users) ->

  userJoinBattle = (battle, user, deckId, res) ->
    if battle.users.length >= 2
      res.send 400, 'Battle full'
    else if deckId not in user.decks
      res.send 400, "Invalid deck #{deckId}"
    else if user._id in battle.users or user.activeBattle?
      res.send 400, 'Already in battle'
    else
      battle.users.push user._id
      user.activeBattle = battle._id
      Decks.get deckId, (err, deck) ->
        if err?
          res.send 500, err
        else
          battle.addPlayer user._id, deck, (err, player) ->
            if err?
              res.send 500, err
            else
              async.series [battle.save.bind(battle), user.save.bind(user)], (err) ->
                if err?
                  res.send 500, err
                else
                  res.json battle.getPublicData()

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
            userJoinBattle battle, user, deckId, res

  # Host battle
  app.post '/secure/battle/host', (req, res) ->
    deckId = req.body.deck
    Users.fromSession req.session.user, (err, user) ->
      if err?
        res.send 500, err
      else
        Battles.create (err, battle) ->
          if err?
            res.send 500, err
          else
            userJoinBattle battle, user, deckId, res

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

  # Get active battle
  app.get '/secure/battle/active', (req, res) ->
    Users.fromSession req.session.user, (err, user) ->
      if err?
        res.send 500, err
      else
        if not user.activeBattle?
          res.json null
        else
          Battles.get user.activeBattle, (err, battle) ->
            if err?
              res.send 500, err
            else
              res.json battle.getPublicData()

  # Get all active battles
  app.get '/battle', (req, res) ->
    Battles.getAll (err, battles) ->
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
        res.json battle.getPublicData()
      else
        res.send 400, "Bad battle id #{id}"
