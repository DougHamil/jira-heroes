define ['jquery'], ($) ->

  class JiraHeroesApi
    # - Static
    @LoadStaticData: (cb) ->
      @GetHeroes (heroes) =>
        @heroes = {}
        for hero in heroes
          @heroes[hero._id] = hero
        console.log "Loaded #{heroes.length} heroes"
        @GetAllCards (cards) =>
          @cards = {}
          for card in cards
            @cards[card._id] = card
          console.log "Loaded #{cards.length} cards"
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
    @GetOpenBattles: (cb) ->
      $.get '/battle/open', cb
    @GetAllBattles: (cb) ->
      $.get '/battle', cb
    @GetBattle: (battleId, cb) ->
      $.get "/battle/#{battleId}", cb
    @GetActiveBattles: (cb) ->
      $.get '/secure/battle/active', cb
    @QueryBattles: (query, cb) ->
      $.post '/battle/query', {query:query}, cb
    @HostBattle: (addBot, deckId, cb) ->
      $.post '/secure/battle/host', {deck:deckId, bot:addBot}, cb
    @JoinBattle: (battleId, deckId, cb) ->
      $.post "/secure/battle/#{battleId}/join", {deck:deckId}, cb

    # - User
    @GetUsers: (userIds, cb) ->
      $.post '/user/find', {users:JSON.stringify(userIds)}, cb
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
