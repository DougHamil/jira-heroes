define ['jiraheroes', 'engine', 'gui', 'pixi'], (JH, engine, GUI) ->

  class MainMenu extends PIXI.DisplayObjectContainer
    constructor: (@manager, stage) ->
      super
      @myStage = stage
      @menuText = new PIXI.Text 'JIRA Heroes', GUI.STYLES.HEADING
      @pointsText = new GUI.GlyphText '0 <coin>'
      @hostBtn = new GUI.TextButton 'Host Battle'
      @joinBtn = new GUI.TextButton 'Join Battle'
      @decksBtn = new GUI.TextButton 'Decks'
      @libraryBtn = new GUI.TextButton 'Library'
      @hostBtn.position = {x:(engine.WIDTH/2) - @hostBtn.width/2, y:(engine.HEIGHT/2)}
      @joinBtn.position = {x:(engine.WIDTH/2) - @joinBtn.width/2, y:@hostBtn.position.y + 2 * @joinBtn.height}
      @decksBtn.position = {x:(engine.WIDTH/2) - @decksBtn.width/2, y:@joinBtn.position.y + 2 * @decksBtn.height}
      @libraryBtn.position = {x:(engine.WIDTH/2) - @libraryBtn.width/2, y:@decksBtn.position.y + 2 * @libraryBtn.height}
      console.log @pointsText.width
      @pointsText.position = {x: engine.WIDTH - @pointsText.width - 20, y: engine.HEIGHT - @pointsText.height - 20}
      @libraryBtn.onClick =>
        @manager.activateView 'Library'
      @.addChild @menuText
      @.addChild @hostBtn
      @.addChild @joinBtn
      @.addChild @decksBtn
      @.addChild @libraryBtn
      @.addChild @pointsText

    deactivate: ->
      @myStage.removeChild @

    activate: ->
      @myStage.addChild @
