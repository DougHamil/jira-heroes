Cards = require '../models/card'

module.exports = (app) ->
  app.get '/', (req, res) ->
    if req.session.user?
      justLoggedIn = req.session.justLoggedIn?
      req.session.justLoggedIn = null
      res.render 'index', { entryModule: 'game/main', user: req.session.user, justLoggedIn:justLoggedIn}
    else
      res.redirect '/login'

  app.get '/stats', (req, res) ->
    Cards.getAll (err, cards) ->
      if err?
        res.send 500, err
      else
        modCards = []
        for card in cards
          cardObj = card.toObject()
          cardObj.isSpell = card.isSpellCard()
          cardObj.isMinion = !cardObj.isSpell
          modCards.push cardObj
        res.render 'stats', {entryModule: 'stats', cards:modCards}

  app.get '/login', (req, res) ->
    data =
      failed: req.session.loginFailed?
      entryModule: 'login'
    delete req.session.loginFailed
    res.render 'login', data

  console.log 'Initialized views controller.'
