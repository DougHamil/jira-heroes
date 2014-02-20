require.config
  baseUrl: 'js'
  shim:
    d3:
      exports: 'd3'
  paths:
    d3: '../lib/d3.min'
    jquery: '../lib/jquery'
    jiraheroes: './jiraheroes'
    eventemitter: './eventemitter'

define ['jquery', 'jiraheroes', 'd3'], ($, JH, d3) ->
  $(document).ready ->
    console.log "D3 Version #{d3.version}"
    minions = cards.filter (c) -> c.isMinion
    console.log minions
    spells = cards.filter (c) -> c.isSpell
    els = d3.select("body").append("div")

    _update = (data)->
      el = els.selectAll("div").data(data)
      el.enter().append("div").text((c) -> c.displayName)
      el.exit().remove()
      el.text((c) -> c.displayName).attr("class", (c) -> if c.isSpell then "spell" else "minion")

    _update(cards)

    $("#spellsToggleBtn").click ->
      if $("#spellsToggleBtn").val() is 'Hide Spells'
        _update(minions)
        $("#spellsToggleBtn").val("Show Spells")
      else
        _update(cards)
        $("#spellsToggleBtn").val("Hide Spells")
    $("#sizeByHealthBtn").click ->
      els.selectAll("div").transition().style 'font-size', (d) -> ((d.health*3)+12) + "px"
    $("#sizeByDamageBtn").click ->
      els.selectAll("div").transition().style 'font-size', (d) -> ((d.damage*3)+12) + "px"

