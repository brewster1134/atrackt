###
Atrackt Tracking Library
@version 0.4.0
@author Ryan Brewster
###

# IE Console support
window.console = { log: -> } unless window.console?

window.Atrackt =
  plugins: {}

  registerPlugin: (name, attrs) ->
    return console.log "NO SEND METHOD DEFINED!" unless typeof attrs.send is 'function'

    console.log 'ATRACKT PLUGIN REGISTERED', name, attrs

    # Create bindEvents method
    attrs.bindEvents = (eventsObject) =>
      attrs.events = eventsObject
      @_bindEvents eventsObject

    attrs.setOptions = (options) ->
      pluginOptions = attrs.options || {}
      attrs.options = $.extend pluginOptions, options

    # set plugin to global plugins object
    @plugins[name] = attrs

  track: (data, event) ->
    for pluginName, pluginData of @plugins
      if data instanceof jQuery
        # check that the click event is supported and the element matches the selectors for the plugin
        if !event? || ( selectors = pluginData.events[event] && data.is(selectors?.join(','))? )
          pluginData.send @_getTrackObject data,
            plugin: pluginName
      else if data instanceof Object
        pluginData.send @_getTrackObject data,
          plugin: pluginName

  # looks through the dom and re-binds any trackable elements.
  # this is helpful if you are not using livequery and add new elements to the dom via ajax
  refresh: ->
    for pluginName, pluginData of @plugins
      @_bindEvents pluginData.events

  _debug: ->
    @_urlParams('debugTracking') == 'true'

  # builds the object to be passed to the custom send method
  _getTrackObject: (data, additionalData = {}) ->
    trackObject = if data instanceof jQuery
      $el = data

      # run the custom function if its available
      $el.data('track-function')?()

      $el.data 'track-object',
        location: @_getLocation()
        categories: @_getCategories $el
        value: @_getValue $el
        event: @_getEvent $el
      $el.data 'track-object'
    else if data instanceof Object
      $.extend data,
        location: @_getLocation()
      data

    if trackObject
      $.extend trackObject, additionalData
    else
      console.log 'DATA IS NOT TRACKABLE', data
      false


  _getLocation: ->
    $('body').data('track-location') || $(document).attr('title') || document.URL

  _getCategories: ($el) ->
    catArray = []

    # add this element's data-trackkey/value
    catArray.unshift $el.data('track-cat') if $el.data('track-cat')

    # add this element's parents data-trackkey/value
    $el.parents('[data-track-cat]').each ->
      catArray.unshift $(@).data('track-cat')

    catArray

  _getValue: ($el) ->
    $el.attr('title') || $el.attr('name') || $el.text() || $el.val() || $el.attr('id') || $el.attr('class')

  _getEvent: ($el) ->
    $el.data('track-event')# || @defaults.event

  # bind events based on custom events object
  _bindEvents: (eventsObject) ->
    return false unless eventsObject

    for eventType, selectorArray of eventsObject
      selectors = $(selectorArray.join(','))

      selectors.each (index, selector) ->
        $(selector).data 'track-event', eventType

      if $(document).livequery?
        selectors.livequery ->
          Atrackt._initEl $(@)
      else
        selectors.each ->
          Atrackt._initEl $(@)

  # bind an individual element
  _initEl: ($el) ->
    $el.on @_getEvent($el), (e) ->
      Atrackt.track $el, e.type

    @_debugEl $el if @_debug()

  # build an object of url paramaters.
  # @param pass an optional key to just return that value
  _urlParams: (key = null) ->
    params = {}
    paramString = window.location.search.substring(1)
    $.each paramString.split('&'), (i, param) ->
      paramObject = param.split('=')
      params[paramObject[0]] = paramObject[1]
    if key
      params[key]
    else
      params

  # DEBUGGING UI
  #

  # Add the debugging console template to the dom
  _debugConsole: ->
    $ =>
      $('body').addClass('tracking-debug')
      Atrackt.debugConsole = $('<div id="tracking-debug">').append(
        '<div id="tracking-debug-content">' +
        '<div id="tracking-location">Location: ' + @_getLocation() + '</div>' +
        '<div id="tracking-current-element">Hover over an element to see the tracked data associated with it.</div>' +
        '<table class="table" id="tracking-elements">' +
        '<thead><tr>' +
        '<th>Categories</th>' +
        '<th>Value</th>' +
        '<th>Event</th>' +
        '<th>Error</th>' +
        '</tr></thead>' +
        '<tbody></tbody>' +
        '</table>' +
        '</div>' +
        '</div>'
      ).prependTo('body')

  # Add each tracked element to the console
  _debugEl: ($el) ->
    # set track-object since we want to show the data before it gets tracked.
    @_getTrackObject $el

    _elId = @_debugElementId $el
    $el.attr 'id', _elId

    _consoleCurrentElement = Atrackt.debugConsole.find('#tracking-current-element')
    _consoleBody = Atrackt.debugConsole.find('#tracking-elements tbody')
    _consoleBody.append(
      '<tr class="tracking-element" id=' + _elId + '>' +
      '<td class="tracking-categories">' + $el.data('track-object').categories + '</td>' +
      '<td class="tracking-value">' + $el.data('track-object').value + '</td>' +
      '<td class="tracking-event">' + $el.data('track-object').event + '</td>' +
      '<td class="tracking-error"></td>' +
      '</tr>'
    )

    # errors:
    # if element with the same tracking information exists...
    mathingEls = $('body #' + _elId)
    matchingConsoleEls = mathingEls.filter('.tracking-element')
    matchingBodyEls = mathingEls.not('.tracking-element')

    if matchingBodyEls.length > 1
      console.log 'THERE ARE DUPLICATE ELEMENTS!', matchingBodyEls
      matchingConsoleEls.addClass 'error'
      matchingConsoleEls.find('.tracking-error').append('DUPLICATE')

    # events
    # events for elements in the console log
    matchingConsoleEls.hover ->
      $el.addClass 'tracking-highlight'
      $('html, body').stop().animate
        scrollTop: $el.offset().top - $('#tracking-debug').height() - 20
      , 500
    , ->
      $el.removeClass 'tracking-highlight'

    # events for elements on the page
    $el.hover ->
      $(@).addClass 'tracking-highlight'
      _consoleCurrentElement.html(
        '<dt>Categories</dt><dd>' + $(@).data('track-object').categories + '</dd>' +
        '<dt>Value</dt><dd>' + $(@).data('track-object').value + '</dd>' +
        '<dt>Event</dt><dd>' + $(@).data('track-object').event + '</dd>'
      )
    , ->
      $(@).removeClass 'tracking-highlight'

  # Build a unique ID for each element
  _debugElementId: ($el) ->
    _categories = $el.data('track-object').categories
    _ctaValue = $el.data('track-object').value
    _event = $el.data('track-object').event

    idArray = []
    idArray.push _categories if _categories
    idArray.push _ctaValue if _ctaValue
    idArray.push _event if _event

    idArray.join().toLowerCase().replace(/[^\w]/g, '')

Atrackt.refresh()
Atrackt._debugConsole() if Atrackt._debug()
