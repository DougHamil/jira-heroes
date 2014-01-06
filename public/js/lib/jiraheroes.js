// Generated by CoffeeScript 1.6.3
(function() {
  define(['jquery'], function($) {
    var JiraHeroesApi;
    return JiraHeroesApi = (function() {
      function JiraHeroesApi() {}

      JiraHeroesApi.GetAllCards = function(cb) {
        return $.get('/card', cb);
      };

      JiraHeroesApi.GetCard = function(cardId, cb) {
        return $.get("/card/" + cardId, cb);
      };

      JiraHeroesApi.GetAllDecks = function(cb) {
        return $.get('/secure/deck', cb);
      };

      JiraHeroesApi.GetDeck = function(deckId, cb) {
        return $.get("/secure/deck/" + deckId, cb);
      };

      JiraHeroesApi.CreateNewDeck = function(name, heroId, cb) {
        return $.post("/secure/deck", {
          name: name,
          hero: heroId
        }, cb);
      };

      JiraHeroesApi.SetDeckCards = function(deckId, cardIds, cb) {
        return $.post("/secure/deck/" + deckId + "/cards", {
          cards: cardIds
        }, cb);
      };

      JiraHeroesApi.GetAllBattles = function(cb) {
        return $.get('/battle', cb);
      };

      JiraHeroesApi.GetBattle = function(battleId, cb) {
        return $.get("/battle/" + battleId, cb);
      };

      JiraHeroesApi.GetActiveBattle = function(cb) {
        return $.get('/secure/battle/active', cb);
      };

      JiraHeroesApi.QueryBattles = function(query, cb) {
        return $.post('/battle/query', {
          query: query
        }, cb);
      };

      JiraHeroesApi.HostBattle = function(deckId, cb) {
        return $.post('/secure/battle/host', {
          deck: deckId
        }, cb);
      };

      JiraHeroesApi.JoinBattle = function(battleId, deckId, cb) {
        return $.post("/secure/battle/" + battleId + "/join", {
          deck: deckId
        }, cb);
      };

      JiraHeroesApi.GetUser = function(cb) {
        return $.get('/secure/user', cb);
      };

      JiraHeroesApi.GetUserLibrary = function(cb) {
        return $.get('/secure/user/library', cb);
      };

      JiraHeroesApi.AddCardToUserLibrary = function(cardId, success, fail) {
        var req;
        req = $.post('/secure/user/library', {
          card: cardId
        }, success);
        return req.fail(fail);
      };

      JiraHeroesApi.GetHeroes = function(cb) {
        return $.get('/hero', cb);
      };

      JiraHeroesApi.GetHero = function(heroId, cb) {
        return $.get("/hero/" + heroId, cb);
      };

      return JiraHeroesApi;

    })();
  });

}).call(this);
