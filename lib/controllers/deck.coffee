UserController = require './user'
HeroClass = require '../models/hero.class'
Deck = require '../models/deck'

module.exports = (app, Users) ->
  # Create a new deck
  app.post '/secure/deck', (req, res) ->
    hero = req.body.hero
    name = req.body.name
    # TODO: Validate name
    if not hero? or not name?
      res.send 400, "Expected 'hero' and 'name'"
    else
      HeroClass.fromName hero, (err, heroClass) ->
        if err? or not heroClass?
          res.send 400, "Bad hero class #{hero}"
        else
          Deck.create (err, deck) ->
            if err?
              res.send 500, err
            else
              deck.user = req.session.user._id
              deck.hero.class = hero
              deck.name = name
              deck.cards = []
              deck.save (err) ->
                if not err?
                  Users.fromSession req.session.user, (err, user) ->
                    if not err?
                      user.decks.push deck._id
                      user.save (err) ->
                        if not err?
                          req.session.user = user
                          res.send 200, deck._id
                        else
                          res.send 500, err
                    else
                      res.send 500, err
                else
                  res.send 500, err

  # Get all decks
  app.get '/secure/deck', (req, res) ->
    user = req.user
    if user.decks.length > 0
      Deck.model.find({_id:{ $in: user.decks}}).exec (err, decks) ->
        if err?
          res.send 500, err
        else
          res.json decks
    else
      res.json []

  # Get a specific deck
  app.get '/secure/deck/:id', (req, res) ->
    id = req.params.id
    user = req.user
    if not id in user.decks
      res.send 400, "Invalid deck ID: #{id}"
    else
      Deck.get id, (err, deck) ->
        if err?
          res.send 500, err
        else if deck?
          res.json deck
        else
          res.send 400, id
  console.log "Initialized deck controller."
