define ['jquery', 'jiraheroes', 'engine', 'gui', 'pixi'], ($, JH, engine, GUI) ->
  BACKGROUND_TEXTURE = PIXI.Texture.fromImage '/media/images/backgrounds/heromenu.png'
  class CreateHeroMenu extends PIXI.DisplayObjectContainer
    constructor: (@manager, stage) ->
      super
      @heroNameEl = $("#heroName")
      @heroNameEl.hide()
      @heroNameText = $("#heroNameText")
      @heroNameSave = $("#heroNameSave")
      @heroNameCancel = $("#heroNameCancel")
      @myStage = stage
      @bgSprite = new PIXI.Sprite BACKGROUND_TEXTURE
      @menuText = new PIXI.Text 'Create a Hero', GUI.STYLES.HEADING
      @backBtn = new GUI.TextButton 'Back'
      @backBtn.position = {x:(engine.WIDTH/2), y:(engine.HEIGHT/2) + 2 * @backBtn.height}
      @backBtn.onClick =>
        @manager.activateView 'HeroMenu'
      #@.addChild @bgSprite
      @.addChild @menuText
      @.addChild @backBtn
      @heroNameSave.click =>
        @createHero()
      @heroNameCancel.click =>
        @heroNameEl.hide()

      JH.GetHeroMetaData (classes) =>
        x = 50
        y = 100
        nameHeroFunc = (clazz) =>
          return =>
            @heroNameEl.show()
            @selectedClass = clazz
        for heroClass in classes
          btn = new GUI.HeroButton {name: '', class:heroClass.name, media:heroClass.media}
          btn.position = {x:x, y:y}
          btn.onClick nameHeroFunc(heroClass)
          x += 300
          @.addChild btn

    createHero: ->
      if @selectedClass?
        name = @heroNameText.val()
        #TODO Validate name
        JH.CreateHero name, @selectedClass.name, (heroId) =>
          console.log "Created hero #{heroId}"
          @heroNameEl.hide()
          @heroNameText.val ''
          @manager.activateView 'HeroMenu'

    deactivate: ->
      @myStage.removeChild @

    activate: ->
      @myStage.addChild @
