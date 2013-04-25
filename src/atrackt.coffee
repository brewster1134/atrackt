###
Atrackt Tracking Library
https://github.com/brewster1134/atrackt
@version 0.0.6
@author Ryan Brewster
###

# IE Console support
window.console = { log: -> } unless window.console?

window.Atrackt =
  plugins: {}

  # PUBLIC METHODS
  #

  registerPlugin: (name, attrs) ->
    return console.log "NO SEND METHOD DEFINED" unless typeof attrs?.send is 'function'
    console.log 'ATRACKT PLUGIN REGISTERED', name, attrs
    attrs.events ||= {}

    # Create bind method
    attrs.bind = (eventsObject) =>
      for event, selectors of eventsObject
        currentSelectors = attrs.events[event] || []
        attrs.events[event] = _.union currentSelectors, selectors
      $ =>
        @_bind name, eventsObject

    attrs.unbind = (eventsObject) =>
      if eventsObject?
        for event, selectors of eventsObject
          currentSelectors = attrs.events[event] || []
          attrs.events[event] = _.difference currentSelectors, selectors
          delete attrs.events[event] if attrs.events[event].length == 0
      else
        attrs.events = {}
      $ =>
        @_unbind name, eventsObject

    attrs.setOptions = (options) ->
      pluginOptions = attrs.options || {}
      attrs.options = $.extend true, pluginOptions, options

    # set plugin to global plugins object
    @plugins[name] = attrs

  bind: (eventsObject) ->
    for pluginName, pluginData of @plugins
      pluginData.bind eventsObject

  unbind: (eventsObject) ->
    for pluginName, pluginData of @plugins
      pluginData.unbind eventsObject

  # looks through the dom and re-binds any trackable elements.
  # this is helpful if you are not using livequery and add new elements to the dom via ajax
  refresh: ->
    # clear the debugging console if debugging is enabled
    $('#atrackt-elements tbody').empty() if @_debug?()

    # unbind all atrackt events form all elements
    $('*').off '.atrackt'

    # loop through the plugins and re-bind the registered events/elements
    for pluginName, pluginData of @plugins
      @_bind pluginName, pluginData.events

    true

  track: (data, event) ->
    for pluginName, pluginData of @plugins

      if data instanceof jQuery
        # check the event is in the plugin's event namespace
        if !event? || event.handleObj.namespace == "atrackt.#{pluginName}"
          pluginData.send @_getTrackObject data,
            event:  event?.type
            plugin: pluginName

      else if data instanceof Object
        pluginData.send @_getTrackObject data,
          plugin: pluginName
    true

  # PRIVATE METHODS
  #

  # bind events based on custom events object
  _bind: (plugin, eventsObject) ->
    return false unless eventsObject

    for event, selectorArray of eventsObject
      selectors = $(selectorArray.join(','))

      if $(document).livequery?
        selectors.livequery ->
          Atrackt._initEl $(@), plugin, event
      else
        selectors.each ->
          Atrackt._initEl $(@), plugin, event

  # initialize an individual element
  _initEl: ($el, plugin, event) ->
    $el.on "#{event}.atrackt.#{plugin}", (e) ->
      Atrackt.track $el, e

    @_debugEl $el, plugin, event if @_debug?()

  # Used to unbind any combination of events/jquery selectors and plugins.
  # You can pass a plugin name, an events object, or both.
  # If both are used, pass the plugin name in first.
  # If no arguments are passed, ALL selectors for ALL plugins are unbound
  #
  # @param plugin [String] name of plugin *optional
  # @param eventsObject [Object] *optional
  #
  _unbind: (plugin, eventsObject) ->
    eventName = ".atrackt.#{plugin}"
    selectors = $('*')

    # if eventsObject is set, loop through and unbind all those events with the event
    if eventsObject?
      for event, selectorArray of eventsObject
        selectors = selectorArray.join(',')
        eventName = event.concat eventName

        @_uninitEls selectors, eventName
    else
      @_uninitEls selectors, eventName

  # un-initialize multiple elements via a jquery selector
  _uninitEls: (selectors, event) ->
    $(selectors).off event

    if $(document).livequery?
      console.log selectors
      $(selectors).expire event

    @_debugRemoveEls selectors if @_debug?()

  # builds the object to be passed to the custom send method
  _getTrackObject: (data, additionalData = {}) ->
    trackObject = if data instanceof jQuery
      $el = data

      $el.data 'track-object',
        location: @_getLocation()
        categories: @_getCategories $el
        value: @_getValue $el

      $.extend $el.data('track-object'), additionalData

      # run the custom function if its available (and pass in current data)
      $el.data('track-function')? $el.data 'track-object'

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
