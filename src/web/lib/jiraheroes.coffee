define ['jquery'], ($) ->
  class JiraHeroesApi
    @CreateHero: (name, clazz, cb) ->
      $.post '/secure/hero/create', {name:name, class:clazz}, cb
    @CreateCampaign: (name, clazz, cb) ->
      $.post '/secure/campaign/create', {name: name, class:clazz}, cb
    @JoinCampaign: (heroId, campaignId, cb) ->
      $.post '/secure/campaign/join', {hero:heroId, campaign:campaignId}, cb
    @GetOpenCampaigns: (cb) ->
      $.ajax
        url: '/secure/campaign'
      .done (data) ->
        cb data
    @GetCampaignMetaData: (cb) ->
      $.ajax
        url: '/secure/metadata/campaign'
      .done (data) ->
        cb data
    @GetCampaign: (id, cb) ->
      $.ajax
        url: '/secure/campaign/'+id
      .done (data) ->
        cb data
    @GetHeroes: (cb) ->
      $.ajax
        url: '/secure/hero'
      .done (data) ->
        cb data
    @GetHeroMetaData: (cb) ->
      $.ajax
        url: '/secure/metadata/hero'
      .done (data) ->
        cb data
