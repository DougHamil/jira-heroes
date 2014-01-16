define ['./views/mainmenu',
        './views/library',
        './views/decks',
        './views/createdeck',
        './views/editdeck',
        './views/hostbattle',
        './views/battle',
        'jiraheroes', 'engine'], (
            MainMenu,
            Library,
            Decks,
            CreateDeck,
            EditDeck,
            HostBattle,
            Battle,
            JH) ->
  class MenuManager
    constructor: (@stage) ->
      @views =
        'MainMenu': new MainMenu @, @stage
        'Library': new Library @, @stage
        'Decks': new Decks @, @stage
        'CreateDeck': new CreateDeck @, @stage
        'EditDeck': new EditDeck @, @stage
        'HostBattle': new HostBattle @, @stage
        'Battle': new Battle @, @stage

    activateView: (view, args...) ->
      if @activeView?
        @activeView.deactivate()
      @views[view].activate(args...)
      @activeView = @views[view]
