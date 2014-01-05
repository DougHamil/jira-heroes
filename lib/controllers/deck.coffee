Heroes = require '../models/hero'
Decks = require '../models/deck'

module.exports = (app, Users) ->
  # Add a card to a deck
  app.post '/secure/deck/:id/cards', (req, res) ->
    id = req.params.id
    cards = req.body.cards
    if not id in req.session.user.decks
      res.send 400, "Invalid deck #{id}"
    else if not cards?
      res.send 400, "Expected 'cards'"
    else
      Users.fromSession req.session.user, (err, user) ->
        if err?
          res.send 500, err
        else
          if not user.ownsCards(cards)
            res.send 400, "User does not own the cards"
          else if cards.length > Decks.MAX_DECK_SIZE
            res.send 400, "Too many cards, maximum number of cards is #{Decks.MAX_DECK_SIZE}"
          else
            # TODO: Validate cards (number of cards, availability to player)
            Decks.get id, (err, deck) ->
              if err?
                res.send 500, err
              else
                deck.cards = cards
                deck.save (err) ->
                  if err?
                    res.send 500, err
                  else
                    res.send 200, id

  # Create a new deck
  app.post '/secure/deck', (req, res) ->
    heroId = req.body.hero
    name = req.body.name
    # TODO: Validate name
    if not heroId? or not name?
      res.send 400, "Expected 'hero' and 'name'"
    else
      Heroes.get heroId, (err, hero) ->
        if err?
          res.send 500, err
        else if not hero?
          res.send 400, "Bad hero class #{hero}"
        else
          Decks.create (err, deck) ->
            if err?
              res.send 500, err
            else
              deck.user = req.session.user._id
              deck.hero.class = heroId
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
      Decks.model.find({_id:{ $in: user.decks}}).exec (err, decks) ->
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
      Decks.get id, (err, deck) ->
        if err?
          res.send 500, err
        else if deck?
          res.json deck
        else
          res.send 400, id
  console.log "Initialized deck controller."
