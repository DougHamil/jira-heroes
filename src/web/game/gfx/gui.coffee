define ['./gfx/herobutton',
        './gfx/textbutton',
        './gfx/campaignbutton',
        './gfx/textfield',
        './gfx/glyphtext',
        './gfx/card',
        './gfx/deckpicker',
        './gfx/deckcardlist',
        './gfx/cardpicker',
        './gfx/battlepicker',
        './gfx/cardfan',
        './gfx/cardtoken',
        './gfx/endturnbutton',
        'engine',
        './gfx/styles'], (
        HeroButton,
        TextButton,
        CampaignButton,
        TextField,
        GlyphText,
        Card,
        DeckPicker,
        DeckCardList,
        CardPicker,
        BattlePicker,
        CardFan,
        CardToken,
        EndTurnButton,
        engine, styles) ->
  GUI =
    HeroButton: HeroButton
    TextButton: TextButton
    CampaignButton: CampaignButton
    GlyphText:GlyphText
    Card:Card
    TextField: TextField
    DeckPicker: DeckPicker
    DeckCardList: DeckCardList
    CardPicker:CardPicker
    BattlePicker:BattlePicker
    CardFan:CardFan
    CardToken: CardToken
    EndTurnButton: EndTurnButton
    STYLES: styles

  return GUI
