###
Atrackt Tracking Library
https://github.com/brewster1134/atrackt
@version 1.1.0
@author Ryan Brewster
###

((factory) ->
  if define?.amd
    define [
      'jquery'
      'atrackt'
      'jquery.scrollTo'
    ], ($, Atrackt) ->
      factory $, Atrackt.constructor
  else
    factory window.jQuery, window.Atrackt.constructor
) ($, Atrackt) ->

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

      super consoleHtml
      @$console = $(consoleHtml)
      $('#atrackt-location', @$console).text @_getLocation()
      $('body').addClass('atrackt-console').prepend @$console

      @_setPlugins()
      @_renderConsoleElements()

    # Override the custom class to just log tracking data to the console
    #
    setPlugin: (pluginName, plugin) ->
      super pluginName, plugin

      if plugin
        # backup original send method and replace send with a simple console log
        plugin._send = plugin.send
        plugin.send = (data, options) ->
          console.log plugin.name, data, options

    _setPlugins: ->
      for pluginName, plugin of @plugins
        unless plugin._send
          @setPlugin pluginName, plugin

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
      self = @

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

        # scroll to hovered element
        if $.scrollTo
          if @ == $rowEl[0]
            $.scrollTo $trackEl, 0,
              offset:
                top: -300
          else if @ == $trackEl[0]
            self.$console.scrollTo $rowEl, 0,
              offset:
                top: -100
      , ->
        $rowEl.removeClass 'atrackt-console-active'
        $trackEl.removeClass 'atrackt-console-active'

  if location.href.indexOf('atracktConsole') > -1
    window.Atrackt = new AtracktConsole
