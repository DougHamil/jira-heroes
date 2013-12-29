Cards = require '../models/card'

module.exports = (app, Users) ->

  # Add a card to user's library
  app.post '/secure/user/library', (req, res) ->
    card = req.body.card
    if not card?
      res.send 400, "Expected 'card'"
    else
      Users.fromSession req.session.user, (err, user) ->
        if err?
          res.send 500, err
        else
          # TODO: Validate and "purchase" card
          if card in user.library
            res.send 400, "Card already in library: #{card}"
          else
            Cards.get card, (err, card) ->
              if err?
                res.send 500, err
              else
                if user.points >= card.cost
                  user.points -= card.cost
                  user.library.push card._id
                  user.save (err) ->
                    if err?
                      res.send 500, err
                    else
                      res.json card
                else
                  res.send 400, "User cannot afford card #{card._id}. Cost is #{card.cost} and user has #{user.points} points available"

  # Get User's card library
  app.get '/secure/user/library', (req, res) ->
    Users.fromSession req.session.user, (err, user) ->
      if err?
        res.send 500, err
      else
        Cards.get user.library, (err, cards) ->
          if err?
            res.send 500, err
          else
            res.json cards

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

  app.post '/card/query', (req, res) ->
    try
      query = JSON.parse(req.body.query)
      Cards.query query, (err, card) ->
        if err?
          res.send 500, err
        else
          res.json card
    catch ex
      res.send 500, ex
