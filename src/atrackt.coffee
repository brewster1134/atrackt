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
      $ =>
        @_bindEvents eventsObject

    attrs.setOptions = (options) ->
      pluginOptions = attrs.options || {}
      attrs.options = $.extend pluginOptions, options

    # set plugin to global plugins object
    @plugins[name] = attrs

  track: (data, event) ->
    for pluginName, pluginData of @plugins
      trackObject = @_getTrackObject data,
        plugin: pluginName

      if data instanceof jQuery
        # check that the click event is supported and the element matches the selectors for the plugin
        if !event? || ( selectors = pluginData.events[event] && data.is(selectors?.join(','))? )
          pluginData.send trackObject

      else if data instanceof Object
        pluginData.send trackObject
    true

  # looks through the dom and re-binds any trackable elements.
  # this is helpful if you are not using livequery and add new elements to the dom via ajax
  refresh: ->
    for pluginName, pluginData of @plugins
      @_bindEvents pluginData.events
    true

  # builds the object to be passed to the custom send method
  _getTrackObject: (data, additionalData = {}) ->
    trackObject = if data instanceof jQuery
      $el = data

      $el.data 'track-object',
        location: @_getLocation()
        categories: @_getCategories $el
        value: @_getValue $el
        event: @_getEvent $el

      # run the custom function if its available (and pass in current data)
      $el.data('track-function')? $el.data 'track-object'

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
    $el.data('track-event')

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

    @_debugEl $el if @_debug?()

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

Atrackt.refresh()
