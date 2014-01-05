define ['./gfx/herobutton',
        './gfx/textbutton',
        './gfx/campaignbutton',
        './gfx/textfield',
        './gfx/glyphtext',
        'engine',
        './gfx/styles'], (HeroButton, TextButton, CampaignButton, TextField, GlyphText, engine, styles) ->
  GUI =
    HeroButton: HeroButton
    TextButton: TextButton
    CampaignButton: CampaignButton
    GlyphText:GlyphText
    TextField: TextField
    STYLES: styles

  return GUI
