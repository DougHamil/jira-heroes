define ['jquery'], ($) ->
  class TextField
    constructor: (position, text) ->
      @el = $('<input type="text">')
      if text?
        @el.val text
      @el.css 'position', 'absolute'
      @el.offset {left:position.x, top:position.y}
      $('#overlay').append @el

    width: ->
      return @el.width()
    height: ->
      return @el.height()
    hide: ->
      @el.hide()
    show: ->
      @el.show()
    setValue: (text) ->
      @el.val(text)
    getValue: ->
      return @el.val()
