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
      @_renderConsoleElements()

    # Re-render console elements
    #
    _renderConsoleElements: ->
      $('tbody', @$console).empty()

      # Render global elements
      for eventType, elements of @_elements
        for element in elements
          @_renderConsoleElement 'ALL', element, eventType

      # Render all plugin elements
      for pluginName, plugin of @plugins
        for eventType, elements of plugin._elements
          for element in elements
            @_renderConsoleElement pluginName, element, eventType

    # Add a single element to the console
    #
    _renderConsoleElement: (plugin, element, eventType) ->
      # Get element meta data
      trackObject = @_getTrackObject element, eventType

      # Build console element html & add it to the dom
      $rowEl = $("<tr><td>#{plugin}</td><td>#{eventType}</td><td>#{trackObject._categories}</td><td>#{trackObject._value}</td></tr>")
      $trackEl = $(element)

      $('tbody', @$console).append $rowEl

      # Create unique id
      elementValueId = trackObject._categories.slice(0)
      elementValueId.push(trackObject._value)
      elementValueId.push(eventType)
      elementValueId = elementValueId.join('-').replace(/[^A-Za-z0-9]+/g, '')

      # Add error class if elements track duplicate data
      if $("##{elementValueId}", @$console).length
        $("##{elementValueId}", @$console).addClass 'error'
        $rowEl.addClass 'error'

      # Give id to both elements
      $trackEl.attr 'data-atrackt-id', elementValueId
      $rowEl.attr 'id', elementValueId

      # Add hover event to console element to highlight both the console and the tracked element
      $rowEl.add($trackEl).hover ->
        $rowEl.addClass 'atrackt-console-active'
        $trackEl.addClass 'atrackt-console-active'
      , ->
        $rowEl.removeClass 'atrackt-console-active'
        $trackEl.removeClass 'atrackt-console-active'
