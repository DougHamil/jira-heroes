define [], ->
  styles =
    DARK_BACKGROUND_COLOR: 0x112233
    BUTTON_COLOR_DISABLED: 0x889999
    BUTTON_COLOR: 0x3399BB
    CARD_PURCHASED_COLOR: 0x00BB00
    CARD_CANT_AFFORD_COLOR: 0xBB0000
    NORMAL_COLOR:0xFFFFFF
    BAD_COLOR:0xB22222
    GOOD_COLOR:0x22B222
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
      font:'64px pixel'

    # These should all have same font-size
    ICON_TEXT_NORMAL:
      stroke:'#000000'
      fill:'#FFFFFF'
      strokeThickness:2
      font:'20px pixel'
    ICON_TEXT_GOOD:
      stroke:'#000000'
      fill:'#22B222'
      strokeThickness:2
      font:'20px pixel'
    ICON_TEXT_BAD:
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
    DISABLED_TEXT:
      stroke:'#000000'
      fill:'#BBBBBB'
      strokeThickness:2
      font:'20px pixel'
    LARGE_TEXT:
      stroke:'#000000'
      fill:'#FFFFFF'
      strokeThickness:2
      font:'72px pixel'
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
