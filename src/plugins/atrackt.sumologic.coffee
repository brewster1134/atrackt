###
Atrackt Sumo Logic Plugin
https://github.com/brewster1134/atrackt
@author Ryan Brewster
@version 0.0.1
###

((root, factory) ->
  if define?.amd
    define [
      'jquery'
      'atrackt'
    ], ($, Atrackt) ->
      factory jQuery, Atrackt
  else
    factory jquery, Atrackt
) @, ($, Atrackt) ->

  window.Atrackt.setPlugin 'sumologic',
    options: {}

    send: (data, options) ->
      return unless options['type'] == 'error'

      $.ajax
        method: 'POST'
        url: ''
        data: data
