define [], ->
  styles =
    DARK_BACKGROUND_COLOR: 0x112233
    BUTTON_COLOR_DISABLED: 0x889999
    BUTTON_COLOR: 0x3399BB
    CARD_PURCHASED_COLOR: 0x00BB00
    CARD_CANT_AFFORD_COLOR: 0xBB0000
    HEADING:
      stroke: 'black'
      fill:'#77DDEE'
      strokeThickness:5
      font:'40px pixel'
    BUTTON_TEXT:
      stroke:'#000000'
      fill:'#FFFFFF'
      strokeThickness:2
      font:'20px pixel'
    DAMAGE_TEXT:
      stroke:'#000000'
      fill:'#B22222'
      strokeThickness:2
      font:'20px pixel'
    TEXT_WARN:
      stroke:'#000000'
      fill:'#B22222'
      strokeThickness:2
      font:'20px pixel'
    TEXT:
      stroke:'#000000'
      fill:'#FFFFFF'
      strokeThickness:2
      font:'20px pixel'
    CARD_TITLE:
      stroke: '#002244'
      fill:'#FFFFFF'
      strokeThickness:0
      font:'20px pixel'
    CARD_STAT:
      stroke: '#000000'
      fill:'#FFFFFF'
      strokeThickness:2
      font:'24px pixel'
    CARD_DESCRIPTION:
      stroke: '#00000'
      fill:'#FFFFFF'
      strokeThickness:0
      font:'13px pixel'
      wordWrap: true
      wordWrapWidth:123
  return styles
