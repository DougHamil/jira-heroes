define ['jquery'], ($) ->

  class JiraHeroesApi
    # - Static
    @LoadStaticData: (cb) ->
      @GetHeroes (heroes) =>
        @heroes = heroes
        cb()

    # - Card
    @GetAllCards: (cb) ->
      $.get '/card', cb
    @GetCard: (cardId, cb) ->
      $.get "/card/#{cardId}", cb

    # - Deck
    @GetAllDecks: (cb) ->
      $.get '/secure/deck', cb
    @GetDeck: (deckId, cb) ->
      $.get "/secure/deck/#{deckId}", cb
    @CreateNewDeck: (name, heroId, cb) ->
      $.post "/secure/deck", {name:name, hero:heroId}, cb
    @SetDeckCards: (deckId, cardIds, cb) ->
      $.post "/secure/deck/#{deckId}/cards", {cards:cardIds}, cb

    # - Battle
    @GetAllBattles: (cb) ->
      $.get '/battle', cb
    @GetBattle: (battleId, cb) ->
      $.get "/battle/#{battleId}", cb
    @GetActiveBattle: (cb) ->
      $.get '/secure/battle/active', cb
    @QueryBattles: (query, cb) ->
      $.post '/battle/query', {query:query}, cb
    @HostBattle: (deckId, cb) ->
      $.post '/secure/battle/host', {deck:deckId}, cb
    @JoinBattle: (battleId, deckId, cb) ->
      $.post "/secure/battle/#{battleId}/join", {deck:deckId}, cb

    # - User
    @GetUser: (cb) ->
      $.get '/secure/user', cb
    @GetUserLibrary: (cb) ->
      $.get '/secure/user/library', cb
    @AddCardToUserLibrary: (cardId, success, fail) ->
      req = $.post '/secure/user/library', {card:cardId}, success
      req.fail fail

    # - Hero
    @GetHeroes: (cb) ->
      $.get '/hero', cb
    @GetHero: (heroId, cb) ->
      $.get "/hero/#{heroId}", cb
