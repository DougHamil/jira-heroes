HeroCache = require '../models/herocache'

module.exports = (app, Users) ->

  # Get all hero metadata
  app.get '/hero', (req, res) ->
    HeroCache.getAll (err, heroes) ->
      if err?
        res.send 500, err
      else
        res.json heroes

  # Get a single hero metadata
  app.get '/hero/:id', (req, res) ->
    heroId = req.params.id
    HeroCache.get heroId, (err, hero) ->
      if err?
        res.send 500, err
      else if not hero?
        res.send 400, "Invalid hero ID: #{heroId}"
      else
        res.json hero
