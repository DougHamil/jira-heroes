Heroes = require '../models/hero'
Decks = require '../models/deck'
Cards = require '../models/card'

# Make sure the cards chosen are valid for this deck
validateCardsForDeck = (deck, cardIds, cb) ->
  Heroes.get deck.hero.class, (err, hero) ->
    if err?
      cb err
    else
      Cards.get cardIds, (err, cards) ->
        if err?
          cb err
        else
          cardLimits = {}
          cardCounts = {}
          for cardId in cardIds
            if not cardCounts[cardId]?
              cardCounts[cardId] = 1
            else
              cardCounts[cardId]++
          for card in cards
            if card.hidden? and card.hidden
              cb "Card #{card.name} is a hidden card and cannot be used in a deck"
              return
            if card.deckLimit? and cardCounts[card._id]? and cardCounts[card._id] > card.deckLimit
              cb "Limit of #{card.deckLimit} instances of #{card.name} per deck."
              return
            if card.heroRequirement? and card.heroRequirement.length > 0 and hero.name not in card.heroRequirement
              cb "Card #{card.name} is only valid for heroes: #{card.heroRequirement}"
              return
          cb null

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
          if not app.isTest? and not user.ownsCards(cards)
            res.send 400, "User does not own the cards"
          else if cards.length > Decks.MAX_DECK_SIZE
            res.send 400, "Too many cards, maximum number of cards is #{Decks.MAX_DECK_SIZE}"
          else
            Decks.get id, (err, deck) ->
              if err?
                res.send 500, err
              else
                validateCardsForDeck deck, cards, (validationError) ->
                  if validationError? and not app.isTest?
                    res.send 400, validationError
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
