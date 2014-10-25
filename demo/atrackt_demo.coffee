$ ->
  Atrackt.setPlugin 'Demo Plugin',
    send: ->

  Atrackt.setEvent
    click: '.track'

  $('a.custom').data 'atrackt-function', ->
    console.log 'Custom Function Called!'
