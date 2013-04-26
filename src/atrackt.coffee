###
Atrackt Tracking Library
https://github.com/brewster1134/atrackt
@version 0.0.7
@author Ryan Brewster
###

(($, window, document) ->

  # IE Console support
  window.console = { log: -> } unless window.console?

  window.Atrackt =
    plugins: {}

    # PUBLIC METHODS
    #

    registerPlugin: (pluginName, attrs) ->
      return console.log "NO SEND METHOD DEFINED" unless typeof attrs?.send is 'function'
      console.log 'ATRACKT PLUGIN REGISTERED', pluginName, attrs
      attrs.include ||= {}
      attrs.exclude ||= {}

      # Create bind method
      attrs.bind = (eventsObject) =>
        for event, selectors of eventsObject
          currentSelectors = attrs.include[event] || []
          attrs.include[event] = _.union currentSelectors, selectors
        $ =>
          @_bind pluginName

      attrs.unbind = (eventsObject) =>
        if eventsObject?
          for event, selectors of eventsObject
            currentSelectors = attrs.exclude[event] || []
            attrs.exclude[event] = _.union currentSelectors, selectors
          $ =>
            @_unbind pluginName, attrs.exclude
        else
          attrs.include = {}
          attrs.exclude = {}
          $ =>
            @_unbind pluginName

      attrs.setOptions = (options) ->
        pluginOptions = attrs.options || {}
        attrs.options = $.extend true, pluginOptions, options

      # set plugin to global plugins object
      @plugins[pluginName] = attrs

    bind: (eventsObject) ->
      for pluginName, pluginData of @plugins
        pluginData.bind eventsObject

    unbind: (eventsObject) ->
      for pluginName, pluginData of @plugins
        pluginData.unbind eventsObject

    # looks through the dom and re-binds any trackable elements.
    refresh: ->
      @_debugConsoleReset()

      # loop through the plugins and re-bind the registered events/elements
      for pluginName, pluginData of @plugins
        @_bind pluginName

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

    # Bind events to elements based on custom events object
    _bind: (plugin) ->
      # clear all existing event bindings so events don't fire twice if it has already been bound
      @_unbind plugin

      includeObject = @plugins[plugin].include
      excludeObject = @plugins[plugin].exclude

      for event, selectorArray of includeObject
        # match all the include selectors and remove the excluded ones
        includeSelectors = selectorArray.join(',')
        excludeSelectors = (excludeObject[event] || []).join(',')
        selectors = $(includeSelectors).not(excludeSelectors)

        selectors.on "#{event}.atrackt.#{plugin}", (e) ->
          Atrackt.track $(@), e

        selectors.each ->
          Atrackt._debugEl $(@), plugin, event

    # Unbind any combination of events/jquery selectors and plugins.
    # You can pass a plugin name, an events object, or both.
    # If both are used, pass the plugin name in first.
    # If no arguments are passed, ALL selectors for ALL plugins are unbound
    #
    # @param plugin [String] name of plugin *optional
    # @param eventsObject [Object] *optional
    #
    _unbind: (plugin, eventsObject) ->
      eventName = ".atrackt.#{plugin}"
      selectors = $('*', 'body')

      # if eventsObject is set, loop through and unbind all those events with the event
      if eventsObject?
        for event, selectorArray of eventsObject
          selectors = $(selectorArray.join(','))
          eventName = event.concat eventName

          selectors.off eventName
      else
        selectors.off eventName

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

) jQuery, window, document
