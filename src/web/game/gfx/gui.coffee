define ['./gfx/herobutton',
        './gfx/textbutton',
        './gfx/campaignbutton',
        './gfx/textfield',
        'engine',
        './gfx/styles'], (HeroButton, TextButton, CampaignButton, TextField, engine, styles) ->
  GUI =
    HeroButton: HeroButton
    TextButton: TextButton
    CampaignButton: CampaignButton
    TextField: TextField
    STYLES: styles

  return GUI
