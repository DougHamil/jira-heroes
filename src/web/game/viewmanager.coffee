define ['./views/mainmenu',
        './views/campaign',
        './views/campaignmenu',
        './views/library',
        './views/decks',
        './views/createdeck',
        './views/editdeck',
        'jiraheroes', 'engine'], (
            MainMenu,
            Campaign,
            CampaignMenu,
            Library,
            Decks,
            CreateDeck,
            EditDeck,
            JH) ->
  class MenuManager
    constructor: (@stage) ->
      @views =
        'MainMenu': new MainMenu @, @stage
        'Library': new Library @, @stage
        'Campaign': new Campaign @, @stage
        'CampaignMenu': new CampaignMenu @, @stage
        'Decks': new Decks @, @stage
        'CreateDeck': new CreateDeck @, @stage
        'EditDeck': new EditDeck @, @stage

    activateView: (view, args...) ->
      if @activeView?
        @activeView.deactivate()
      @views[view].activate(args...)
      @activeView = @views[view]
