define ['util', 'jquery', 'jiraheroes', 'gui', 'engine', 'pixi'], (Util, $, JH, GUI, engine) ->
  PLUS_ICON_TEXTURE = PIXI.Texture.fromImage '/media/images/icons/plus.png'

  class GiftView extends PIXI.DisplayObjectContainer
    constructor: (@manager, @myStage) ->
      super
      @heading = new PIXI.Text 'Gifts', GUI.STYLES.HEADING

      @walletText = new PIXI.Text 'Your wallet:', GUI.STYLES.TEXT
      @walletText.position = {x: 20, y:50}
      wallet = {storyPoints:0, bugsReported:0, bugsClosed:0}
      @userWallet = new GUI.Wallet wallet
      @userWallet.position = {x:20, y:@walletText.position.y + @userWallet.height}

      @giftText = new PIXI.Text 'Gift:', GUI.STYLES.TEXT
      @giftText.position = {x:20, y:@userWallet.position.y + @giftText.height + 20}
      @giftAmount = {storyPoints:0, bugsClosed:0, bugsReported:0}
      @giftWallet = new GUI.Wallet @giftAmount
      @giftWallet.position = {x:20, y:@giftText.position.y + @giftWallet.height}

      @nameText = new PIXI.Text 'Username of gift recipient:', GUI.STYLES.TEXT
      @nameText.position = {x:20, y:@giftWallet.position.y + @nameText.height + 20}
      @nameField = new GUI.TextField {x:20, y:@nameText.position.y + @nameText.height}
      @nameField.hide()

      @sendGiftBtn = new GUI.TextButton 'Send Gift'
      @sendGiftBtn.position = {x:20, y:@nameText.position.y + @nameText.height + 50}
      @sendGiftBtn.onClick => @_sendGift()

      @spBtn = new GUI.SpriteButton PLUS_ICON_TEXTURE, {width:16, height:16}
      @spBtn.position = {x:@giftWallet.position.x + 40, y:@giftWallet.position.y+20}
      @bcBtn = new GUI.SpriteButton PLUS_ICON_TEXTURE, {width:16, height:16}
      @bcBtn.position = {x:@giftWallet.position.x + 90, y:@giftWallet.position.y + 20}
      @brBtn = new GUI.SpriteButton PLUS_ICON_TEXTURE, {width:16, height:16}
      @brBtn.position = {x:@giftWallet.position.x + 145, y:@giftWallet.position.y + 20}
      @spBtn.onClick => @_increaseGift 'storyPoints', 1
      @brBtn.onClick => @_increaseGift 'bugsClosed', 1
      @bcBtn.onClick => @_increaseGift 'bugsReported', 1

      @backBtn = new GUI.TextButton 'Back'
      @backBtn.position = {x:20, y:engine.HEIGHT - @backBtn.height - 20}
      @backBtn.onClick => @manager.activateView 'MainMenu'

      @createGiftContainer = new PIXI.DisplayObjectContainer()
      @createGiftContainer.addChild @walletText
      @createGiftContainer.addChild @userWallet
      @createGiftContainer.addChild @giftText
      @createGiftContainer.addChild @giftWallet
      @createGiftContainer.addChild @nameText
      @createGiftContainer.addChild @sendGiftBtn
      @createGiftContainer.addChild @spBtn
      @createGiftContainer.addChild @brBtn
      @createGiftContainer.addChild @bcBtn

      @.addChild @heading
      @.addChild @backBtn
      @.addChild @createGiftContainer
      @createGiftContainer.visible = false

    _sendGift: ->
      @sendGiftBtn.visible = false
      JH.CreateGift @nameField.getValue(), @giftAmount, (err)=>
        if err? and err.responseText?
          alert "Error sending gift: #{err.responseText}"
          @sendGiftBtn.visible = true
        else
          alert "Gift Sent"
          @manager.activateView 'MainMenu'

    _increaseGift: (currency, amount) ->
      curAmount = @userAmount[currency]
      if curAmount >= amount
        @giftAmount[currency] += amount
        @userAmount[currency] -= amount
        @userWallet.update @userAmount
        @giftWallet.update @giftAmount

    activate: (@gifts)->
      @giftAmount = {storyPoints:0, bugsClosed:0, bugsReported:0}
      @giftWallet.update @giftAmount
      @sendGiftBtn.visible = true
      @createGiftContainer.visible = false
      @myStage.addChild engine.fxLayer
      # Called when all gifts have been claimed
      _allOpened = =>
        JH.GetUser (user) =>
          JH.user = user
          @userAmount = Util.clone(JH.user.wallet)
          @userWallet.update @userAmount
          @createGiftContainer.visible = true
          @nameField.show()

      giftboxes = []
      for gift in @gifts
        giftbox = new GUI.GiftBox(gift)
        giftboxes.push giftbox
      if giftboxes.length > 0
        _openNext = =>
          if giftboxes.length > 0
            giftbox = giftboxes.pop()
            @.addChild giftbox
            giftbox.animate().play()
            giftbox.onOpened (gift) =>
              JH.ClaimGift gift._id, =>
                console.log "Gift claimed"
                @.removeChild giftbox
                _openNext()
          else
            _allOpened()
        _openNext()
      else
        _allOpened()
      @myStage.addChild @

    deactivate: ->
      @myStage.removeChild @
      @nameField.hide()
