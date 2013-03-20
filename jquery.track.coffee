#
# Tracking Library
# @version 0.3.0
#
# @author Ryan Brewster
#
window.console = { log: -> } unless window.console?

(($) ->
  defaults =
    event: 'click'
    propLimit: 100
    siteCatalystVer: 14
    selectors: [ 'a', 'button' ]
    delimiters:
      linkName: '/'
      category: '|'
      elementId: '-'
    propMap:
      'location'    : 'prop1'
      'categories'  : 'prop2'
      'ctaValue'    : 'prop3'
      'event'       : 'prop4'
      # globalData
      'model'       : 'prop20'
      'trimline'    : 'prop30'

  init = ->
    initGlobal() unless Track?

    $ ->
      selectors = $(defaults.selectors.join(','))

      if $(document).livequery?
        selectors.livequery ->
          initEl $(@)
      else
        selectors.each ->
          initEl $(@)

  initGlobal = ->
    window.Track =
      globalData: {}
      debug: urlParams('debugTracking') == 'true'
      location: buildLocation()
      refresh: ->
        init()
      send: (trackObject)->
        $.extend trackObject, buildGlobalData()

        # siteCatalyst
        if s? and s.tl
          buildSObject trackObject
          s.tl true, 'o', buildLinkName trackObject
        else
          console.log 'SiteCatalyst script not loaded!'
          console.log trackObject

    if Track.debug
      $ ->
        debugGlobal()

  initEl = (el) ->
    el.data 'track-object', buildElData el

    el.on el.data('track-data').event, (e) ->
      trackEl $(@)

    if Track.debug
      debugEl el

  trackEl = (el) ->
    Track.send el.data('track-object')

  urlParams = (key = null) ->
    params = {}
    paramString = window.location.search.substring(1)
    $.each paramString.split('&'), (i, param) ->
      paramObject = param.split('=')
      params[paramObject[0]] = paramObject[1]
    if key
      params[key]
    else
      params

  debugGlobal = ->
    $('body').addClass('tracking-debug')
    Track.debugConsole = $('<div id="tracking-debug">').append(
      '<div id="tracking-debug-content">' +
      '<h6 id="tracking-location">Location: ' + Track.location + '</h6>' +
      '<table class="table" id="tracking-elements">' +
      '<thead><tr>' +
      '<th>Categories</th>' +
      '<th>CTA</th>' +
      '<th>Event Type</th>' +
      '</tr></thead>' +
      '<tbody></tbody>' +
      '</table>' +
      '</div>' +
      '</div>'
    ).prependTo('body')

  debugEl = (el) ->
    _elId = buildElementId(el)
    _elsDiv = Track.debugConsole.find('#tracking-elements tbody')
    _elDiv = _elsDiv.find('#' + _elId)
    _elContent = $('<tr class="tracking-element" id=' + _elId + '>')

    el.addClass(_elId)
    _elContent.append(
      '<td class="tracking-categories">' + el.data('track-data').categories + '</td>' +
      '<td class="tracking-cta-value">' + el.data('track-data').ctaValue + '</td>' +
      '<td class="tracking-event">' + el.data('track-data').event + '</td>' +
      '</tr>'
    )

    if _elDiv.length == 0
      _elsDiv.append(_elContent)
    else
      _elDiv.replaceWith(_elContent)

    _elsDiv.find('#' + _elId).hover ->
      el.addClass 'tracking-highlight'
      $('html, body').stop().animate
        scrollTop: el.offset().top - $('#tracking-debug').height() - 20
      , 500
    , ->
      el.removeClass 'tracking-highlight'

  keyLookup = (key) ->
    return key if defaults.siteCatalystVer >= 15

    _newKey = defaults.propMap[key]
    console.log 'No mapping for "' + key + '" found.' unless _newKey
    _newKey || key


  # Build methods
  #
  buildGlobalData = ->
    _globalData = {}
    $.each Track.globalData, (k,v) ->
      _globalData[keyLookup k] = v
    _globalData

  buildElData = (el) ->
    el.data 'track-data',
      categories: buildCategories el
      ctaValue: buildCtaValue el
      event: buildEvent el

    _trackObject = {}
    _trackObject[keyLookup('location')]   = Track.location
    _trackObject[keyLookup('categories')] = el.data('track-data').categories
    _trackObject[keyLookup('ctaValue')]   = el.data('track-data').ctaValue
    _trackObject[keyLookup('event')]      = el.data('track-data').event
    _trackObject

  buildLocation = ->
    console.log 'The <body> element does not have the data-track-location attribute set.' unless $('body').data('track-location')
    $('body').data('track-location') || $(document).attr('title') || document.URL

  buildCategories = (el) ->
    catArray = []

    # add this element's data-trackkey/value
    catArray.unshift el.data('track-cat') if el.data('track-cat')

    # add this element's parents data-trackkey/value
    el.parents('[data-track-cat]').each ->
      catArray.unshift $(@).data('track-cat')

    catArray.join defaults.delimiters.category

  buildCtaValue = (el) ->
    el.text() || el.val() || el.attr('id') || el.attr('class')

  buildEvent = (el) ->
    el.data('track-event') || defaults.event

  buildElementId = (el) ->
    _categories = el.data('track-data').categories
    _ctaValue = el.data('track-data').ctaValue
    _event = el.data('track-data').event

    idArray = []
    idArray.push _categories if _categories
    idArray.push _ctaValue if _ctaValue
    idArray.push _event if _event

    idArray.join(defaults.delimiters.elementId).toLowerCase().replace(/[^\w]/g, '')

  # site catalyst specific
  buildSObject = (trackObject) ->
    switch defaults.siteCatalystVer
      when 14
        varsArray = ['products', 'events']
        eventsArray = []
        for i in Array(defaults.propLimit)
          varsArray.push('prop' + (_i + 1))
          varsArray.push('eVar' + (_i + 1))
          eventsArray.push('event' + (_i + 1))
        s.linkTrackVars = varsArray.join(',')
        s.linkTrackEvents = eventsArray.join(',')

        $.extend s, trackObject
      when 15
        s.contextData = trackObject
    s

  buildLinkName = (trackObject) ->
    linkName = []
    switch defaults.siteCatalystVer
      when 14
        linkName = [
          trackObject.prop1,
          trackObject.prop2,
          trackObject.prop3,
        ]
      when 15
        linkName = [
          trackObject.location,
          trackObject.categories,
          trackObject.ctaValue,
        ]

    linkName.join(defaults.delimiters.linkName)

  init()

)(jQuery)
