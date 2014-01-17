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
    STYLES: styles

  return GUI
