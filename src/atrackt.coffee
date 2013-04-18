###
Atrackt Tracking Library
@version 0.4.0
@author Ryan Brewster
###

# IE Console support
window.console = { log: -> } unless window.console?

window.Atrackt =
  plugins: {}

  registerPlugin: (name, options) ->
    @plugins[name] = options
    $ =>
      @_bindEvents options.events

  track: (data) ->
    for pluginName, pluginData of @plugins
      pluginData.send @_getTrackObject data

  # looks through the dom and re-binds any trackable elements.
  # this is helpful if you are not using livequery and add new elements to the dom via ajax
  refresh: ->
    for pluginName, pluginData of @plugins
      @_bindEvents pluginData.events

  _debug: ->
    @_urlParams('debugTracking') == 'true'

  # builds the object to be passed to the custom send method
  _getTrackObject: (data) ->
    if data instanceof jQuery
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
    $el.on @_getEvent($el), ->
      Atrackt.track $el

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

    # ERROR CHECKING
    #
    # if element with the same tracking information exists...
    mathingEls = $('body #' + _elId)
    matchingConsoleEls = mathingEls.filter('.tracking-element')
    matchingBodyEls = mathingEls.not('.tracking-element')

    if matchingBodyEls.length > 1
      console.log 'THERE ARE DUPLICATE ELEMENTS!', matchingBodyEls
      matchingConsoleEls.addClass 'error'
      matchingConsoleEls.find('.tracking-error').append('DUPLICATE')

    matchingConsoleEls.hover ->
      $el.addClass 'tracking-highlight'
      $('html, body').stop().animate
        scrollTop: $el.offset().top - $('#tracking-debug').height() - 20
      , 500
    , ->
      $el.removeClass 'tracking-highlight'

    $el.hover ->
      $(@).addClass 'tracking-highlight'
      _consoleCurrentElement.html JSON.stringify($(@).data('track-object'))
    , ->
      $(@).removeClass 'tracking-highlight'


  # Build a unique ID for each element
  _debugElementId: ($el) ->
    console.log $el.data()
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


# (($) ->
#   defaults =
#     event: 'click'
#     selectors: [ 'a', 'button' ]
#     delimiters:
#       linkName: '/'
#       category: '|'
#       elementId: '-'

#   init = ->
#     initGlobal() unless Atrackt?

#     $ ->
#       selectors = $(defaults.selectors.join(','))

#       if $(document).livequery?
#         selectors.livequery ->
#           initEl $(@)
#       else
#         selectors.each ->
#           initEl $(@)

#   initGlobal = ->
#     window.Atrackt =
#       globalData: {}
#       debug: urlParams('debugTracking') == 'true'
#       location: buildLocation()
#       refresh: ->
#         init()
#       send: (trackObject)->
#         $.extend trackObject, buildGlobalData()

#         # siteCatalyst
#         if s? and s.tl
#           buildSObject trackObject
#           s.tl true, 'o', buildLinkName trackObject
#         else
#           console.log 'SiteCatalyst script not loaded!'
#           console.log trackObject

#     if Atrackt.debug
#       $ ->
#         debugGlobal()

#   initEl = (el) ->
#     el.data 'track-object', buildElData el

#     el.on el.data('track-data').event, (e) ->
#       trackEl $(@)

#     if Atrackt.debug
#       debugEl el

#   trackEl = (el) ->
#     Atrackt.send el.data('track-object')

#   urlParams = (key = null) ->
#     params = {}
#     paramString = window.location.search.substring(1)
#     $.each paramString.split('&'), (i, param) ->
#       paramObject = param.split('=')
#       params[paramObject[0]] = paramObject[1]
#     if key
#       params[key]
#     else
#       params

#   debugGlobal = ->
#     $('body').addClass('tracking-debug')
#     Atrackt.debugConsole = $('<div id="tracking-debug">').append(
#       '<div id="tracking-debug-content">' +
#       '<h6 id="tracking-location">Location: ' + Atrackt.location + '</h6>' +
#       '<table class="table" id="tracking-elements">' +
#       '<thead><tr>' +
#       '<th>Categories</th>' +
#       '<th>CTA</th>' +
#       '<th>Event Type</th>' +
#       '</tr></thead>' +
#       '<tbody></tbody>' +
#       '</table>' +
#       '</div>' +
#       '</div>'
#     ).prependTo('body')

#   debugEl = (el) ->
#     _elId = buildElementId(el)
#     _elsDiv = Atrackt.debugConsole.find('#tracking-elements tbody')
#     _elDiv = _elsDiv.find('#' + _elId)
#     _elContent = $('<tr class="tracking-element" id=' + _elId + '>')

#     el.addClass(_elId)
#     _elContent.append(
#       '<td class="tracking-categories">' + el.data('track-data').categories + '</td>' +
#       '<td class="tracking-cta-value">' + el.data('track-data').ctaValue + '</td>' +
#       '<td class="tracking-event">' + el.data('track-data').event + '</td>' +
#       '</tr>'
#     )

#     if _elDiv.length == 0
#       _elsDiv.append(_elContent)
#     else
#       _elDiv.replaceWith(_elContent)

#     _elsDiv.find('#' + _elId).hover ->
#       el.addClass 'tracking-highlight'
#       $('html, body').stop().animate
#         scrollTop: el.offset().top - $('#tracking-debug').height() - 20
#       , 500
#     , ->
#       el.removeClass 'tracking-highlight'

#   keyLookup = (key) ->
#     return key if defaults.siteCatalystVer >= 15

#     _newKey = defaults.propMap[key]
#     console.log 'No mapping for "' + key + '" found.' unless _newKey
#     _newKey || key


#   # Build methods
#   #
#   buildGlobalData = ->
#     _globalData = {}
#     $.each Atrackt.globalData, (k,v) ->
#       _globalData[keyLookup k] = v
#     _globalData

#   buildElData = (el) ->
#     el.data 'track-data',
#       categories: buildCategories el
#       ctaValue: buildCtaValue el
#       event: buildEvent el

#     _trackObject = {}
#     _trackObject[keyLookup('location')]   = Atrackt.location
#     _trackObject[keyLookup('categories')] = el.data('track-data').categories
#     _trackObject[keyLookup('ctaValue')]   = el.data('track-data').ctaValue
#     _trackObject[keyLookup('event')]      = el.data('track-data').event
#     _trackObject

#   buildLocation = ->
#     console.log 'The <body> element does not have the data-track-location attribute set.' unless $('body').data('track-location')
#     $('body').data('track-location') || $(document).attr('title') || document.URL

#   buildCategories = (el) ->
#     catArray = []

#     # add this element's data-trackkey/value
#     catArray.unshift el.data('track-cat') if el.data('track-cat')

#     # add this element's parents data-trackkey/value
#     el.parents('[data-track-cat]').each ->
#       catArray.unshift $(@).data('track-cat')

#     catArray.join defaults.delimiters.category

#   buildCtaValue = (el) ->
#     el.attr('title') || el.attr('name') || el.text() || el.val() || el.attr('id') || el.attr('class')

#   buildEvent = (el) ->
#     el.data('track-event') || defaults.event

#   buildElementId = (el) ->
#     _categories = el.data('track-data').categories
#     _ctaValue = el.data('track-data').ctaValue
#     _event = el.data('track-data').event

#     idArray = []
#     idArray.push _categories if _categories
#     idArray.push _ctaValue if _ctaValue
#     idArray.push _event if _event

#     idArray.join(defaults.delimiters.elementId).toLowerCase().replace(/[^\w]/g, '')

#   # site catalyst specific
#   buildSObject = (trackObject) ->
#     switch defaults.siteCatalystVer
#       when 14
#         varsArray = ['products', 'events']
#         eventsArray = []
#         for i in Array(defaults.propLimit)
#           varsArray.push('prop' + (_i + 1))
#           varsArray.push('eVar' + (_i + 1))
#           eventsArray.push('event' + (_i + 1))
#         s.linkTrackVars = varsArray.join(',')
#         s.linkTrackEvents = eventsArray.join(',')

#         $.extend s, trackObject
#       when 15
#         s.contextData = trackObject
#     s

#   buildLinkName = (trackObject) ->
#     linkName = []
#     switch defaults.siteCatalystVer
#       when 14
#         linkName = [
#           trackObject.prop1,
#           trackObject.prop2,
#           trackObject.prop3,
#         ]
#       when 15
#         linkName = [
#           trackObject.location,
#           trackObject.categories,
#           trackObject.ctaValue,
#         ]

#     linkName.join(defaults.delimiters.linkName)

#   init()

# )(jQuery)
