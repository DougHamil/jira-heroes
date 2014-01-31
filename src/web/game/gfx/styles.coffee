define [], ->
  styles =
    BUTTON_COLOR_DISABLED: 0xBBBBBB
    BUTTON_COLOR: 0xEB6841
    CARD_PURCHASED_COLOR: 0x00BB00
    CARD_CANT_AFFORD_COLOR: 0xBB0000
    HEADING:
      stroke: 'black'
      fill:'#EB6841'
      strokeThickness:5
      font:'40px silly'
    TEXT:
      stroke:'#000000'
      fill:'#FFFFFF'
      strokeThickness:2
      font:'20px silly'
    CARD_TITLE:
      stroke: '#000000'
      fill:'#000000'
      strokeThickness:0
      font:'20px silly'
    CARD_STAT:
      stroke: '#000000'
      fill:'#FFFFFF'
      strokeThickness:2
      font:'24px silly'
    CARD_DESCRIPTION:
      stroke: '#FFFFFF'
      fill:'#FFFFFF'
      strokeThickness:0
      font:'12px silly'
      wordWrap: true
      wordWrapWidth:140
  return styles
