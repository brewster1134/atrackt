###
Atrackt Tracking Library
https://github.com/brewster1134/atrackt
@version 1.0.2
@author Ryan Brewster
###

((root, factory) ->
  if location.href.indexOf('atracktConsole') > -1
    if typeof define == 'function' && define.amd
      define [
        'jquery'
        'atrackt'
      ], ($, Atrackt) ->
        window.Atrackt = new(factory($, Atrackt.constructor))
    else
      window.Atrackt = new(factory($, Atrackt.constructor))
) @, ($, Atrackt) ->

  class AtracktConsole extends Atrackt

    # Build the console html and add it to the dom
    #
    constructor: ->
      consoleHtml = """
        <div id="atrackt-console">
          <h4>Location: <span id="atrackt-location"></span></h4>
          <table>
            <thead>
              <tr>
                <th>Plugin</th>
                <th>Event</th>
                <th>Categories</th>
                <th>Value</th>
              </tr>
            </thead>
            <tbody>
            </tbody>
          </table>
        <div>
      """

      @$console = $(consoleHtml)
      $('#atrackt-location', @$console).text @_getLocation()
      $('body').addClass('atrackt-console').prepend @$console

    # Override the custom class to just log tracking data to the console
    #
    setPlugin: (pluginName, plugin) ->
      super pluginName, plugin

      if plugin
        # backup original send method and replace send with a simple console log
        plugin._send = plugin.send
        plugin.send = (data, options) ->
          console.log plugin.name, data, options

    # Add console events to elements
    #
    _registerElement: (context, element, event) ->
      super context, element, event

      contextName = if context.name
        context.name
      else
        'ALL'

      @_renderConsoleElement contextName, element, event

    # Add a single element to the console
    #
    _renderConsoleElement: (contextName, element, eventType) ->
      # Get element meta data
      trackObject = @_getTrackObject element, eventType

      # Create unique id
      elementValueId = trackObject._categories.slice(0)
      elementValueId.unshift(trackObject._value)
      elementValueId.unshift(eventType)
      elementValueId = elementValueId.join('-').toLowerCase().replace(/[^a-z]/g, '')

      # Build console element html
      $rowEl = $("<tr><td>#{contextName}</td><td>#{eventType}</td><td>#{trackObject._categories}</td><td>#{trackObject._value}</td></tr>")
      $trackEl = $(element)

      # Add error class if elements track duplicate data
      if $("tr##{elementValueId}", @$console).length
        $("tr##{elementValueId}", @$console).addClass 'error'
        $rowEl.addClass 'error'

      # add row to console
      $('tbody', @$console).append $rowEl

      # Give id to both elements
      $rowEl.attr 'id', elementValueId
      $trackEl.attr 'data-atrackt-id', elementValueId

      # Add hover event to console element to highlight both the console and the tracked element
      $rowEl.add($trackEl).hover ->
        $rowEl.addClass 'atrackt-console-active'
        $trackEl.addClass 'atrackt-console-active'
      , ->
        $rowEl.removeClass 'atrackt-console-active'
        $trackEl.removeClass 'atrackt-console-active'
