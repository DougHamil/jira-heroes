Cards = require '../models/card'

module.exports = (app, Users) ->

  # Get metadata for all cards
  app.get '/card', (req, res) ->
    Cards.getAll (err, cards) ->
      if err?
        res.send 500, err
      else
        res.json cards

  # Get metadata for specific card
  app.get '/card/:id', (req, res) ->
    id = req.params.id
    Cards.get id, (err, card) ->
      if err?
        res.send 500, err
      else
        res.json card
