###
Atrackt Tracking Library
https://github.com/brewster1134/atrackt
@version 0.1.0
@author Ryan Brewster
###

unless String::trim
  String::trim = ->
    @replace /^\s+|\s+$/g,''

(($, _, window, document) ->

  # IE Console support
  window.console ||= { log: -> }

  window.Atrackt =
    plugins: {}

    # PUBLIC METHODS
    #

    registerPlugin: (pluginName, attrs) ->
      return console.log 'NO SEND METHOD DEFINED' unless typeof attrs?.send is 'function'

      attrs.elements ||= {}
      attrs.includeSelectors ||= {}
      attrs.includeElements ||= {}
      attrs.excludeSelectors ||= {}
      attrs.excludeElements ||= {}

      # Create bind method
      attrs.bind = (eventsObject) =>
        return console.log 'NOTHING TO BIND. YOU MUST PASS AN EVENT OBJECT CALLING BIND' unless eventsObject?

        for eventType, data of eventsObject

          # set selectors and elements on the plugin
          if data instanceof Array
            currentSelectors = attrs.includeSelectors[eventType] || []
            attrs.includeSelectors[eventType] = _.union currentSelectors, data

          else if data instanceof jQuery
            currentElements = attrs.includeElements[eventType] || []
            attrs.includeElements[eventType] = _.union currentElements, data

          @_bind pluginName, eventType, data

      attrs.unbind = (eventsObject) =>
        if eventsObject?
          for eventType, data of eventsObject

            # set selectors and elements on the plugin
            if data instanceof Array
              currentSelectors = attrs.excludeSelectors[eventType] || []
              attrs.excludeSelectors[eventType] = _.union currentSelectors, data

            else if data instanceof jQuery
              currentElements = attrs.excludeElements[eventType] || []
              attrs.excludeElements[eventType] = _.union currentElements, data

            @_unbind pluginName, eventType
        else
          # if we are unbinding everything, we can assume that no elements or selectors should be registered
          attrs.elements = {}
          attrs.includeSelectors = {}
          attrs.includeElements = {}
          attrs.excludeSelectors = {}
          attrs.excludeElements = {}

          @_unbind pluginName

      attrs.setOptions = (options) ->
        pluginOptions = attrs.options || {}
        attrs.options = $.extend true, pluginOptions, options

      attrs.setGlobalData = (object) ->
        attrs.globalData ||= {}
        $.extend true, attrs.globalData, object

      attrs.setCallback = (name, callback) ->
        return false unless _.contains(['before', 'after'], name)
        attrs.callbacks ||= {}
        attrs.callbacks[name] = callback

      # set plugin to global plugins object
      @plugins[pluginName] = attrs

    # Global helper methods
    setGlobalData: (object) ->
      for pluginName, pluginData of @plugins
        pluginData.setGlobalData object

    setCallback: (name, callback) ->
      for pluginName, pluginData of @plugins
        pluginData.setCallback name, callback

    bind: (eventsObject) ->
      for pluginName, pluginData of @plugins
        pluginData.bind eventsObject

    unbind: (eventsObject) ->
      for pluginName, pluginData of @plugins
        pluginData.unbind eventsObject

    # looks through the dom and re-binds any trackable elements.
    refresh: ->
      @_debugConsoleReset()

      # loop through all plugins and all the elements and re-bind the registered events
      for pluginName, pluginData of @plugins
        for eventType, selectors of pluginData.elements
          @_bind pluginName, eventType

      true

    track: (data, options = {}, event) ->
      return false unless trackObject = @_getTrackObject data

      for pluginName, pluginData of @plugins
        # prepare tracking data
        trackingData = $.extend true, {}, pluginData.globalData, trackObject, event
        options = $.extend {}, options[pluginName],
          plugin: pluginName

        # call before callback
        pluginData.callbacks?['before']? trackingData, options

        # send the tracking data
        if data instanceof jQuery
          # check the event is in the plugin's event namespace
          if !event? || event.handleObj.namespace == "atrackt.#{pluginName}"
            pluginData.send $.extend(trackingData,
              event:  event?.type
            ), $.extend options,
              el: data

        else if data instanceof Object
          pluginData.send trackingData, options

        # call after callback
        pluginData.callbacks?['after']? trackingData, options
      true

    # PRIVATE METHODS
    #

    # TODO: compare elements with selectors and remove unneccessary elements
    _cleanup: ->

    # _collectElements
    # combines elements that match the selectors with the explicitly bound elements
    #
    # @expect Atrackt.plugins[pluginName].elements[eventType] to be set
    #
    # @param [String] plugin name
    # @param [String] event type
    #
    # @return [jQuery Object] of all matching elements
    #
    _collectElements: (pluginName, eventType) ->
      @_cleanup pluginName, eventType

      plugin = @plugins[pluginName]

      includeSelectors = $(plugin.includeSelectors[eventType]?.join(','))
      includeElements = includeSelectors || []
      _.each plugin.includeElements[eventType] || [], (el) ->
        includeElements = includeElements.add el

      excludeSelectors = $(plugin.excludeSelectors[eventType]?.join(','))
      excludeElements = excludeSelectors || []
      _.each plugin.excludeElements[eventType] || [], (el) ->
        excludeElements = excludeElements.add el

      # remove excluded elements
      allElements = includeElements.not excludeElements

      @plugins[pluginName].elements[eventType] = allElements

      allElements

    # _bind
    # Bind elements to events
    #
    # @param [String] plugin name
    # @param [String] event type
    # @param [Array or jQuery Object] (optional) specific selectors or jquery object to target
    #
    # @return [jQuery Object] all elements that were bound
    #
    _bind: (pluginName, eventType, data) ->
      @_collectElements pluginName, eventType

      # unbind all events so we can re-bind them and ensure no duplicate bindings
      @_unbind pluginName, eventType, data

      selectors = $(@plugins[pluginName].elements[eventType])

      # further filter the data if data is passed
      if data instanceof Array
        selectors = selectors.filter(data.join(','))
      else if data instanceof jQuery
        selectors = data

      selectors.on "#{eventType}.atrackt.#{pluginName}", (e) ->
        Atrackt.track $(@), {}, e

      # add elements to the debug console
      if @_debug?()
        selectors.each ->
          Atrackt._debugEl $(@), pluginName, eventType

      selectors

    # Unbind any combination of events/jquery selectors and plugins.
    # You can pass a plugin name, an events object, or both.
    # If no arguments are passed, ALL selectors for ALL plugins are unbound
    # If both are used, pass the plugin name in first.
    #
    # @param [String] (optional) plugin name
    # @param [String] (optional) event type
    # @param [Array or jQuery Object] (optional) specific selectors or jquery object to target
    #
    # @return [jQuery Object] all elements that were unbound
    #
    _unbind: (pluginName, eventType, data) ->
      eventName = '.atrackt'
      selectors = $('*', 'body')

      # set namespaced event
      eventName = eventType.concat(eventName) if eventType?
      eventName = eventName.concat(".#{pluginName}") if pluginName?

      # set targeted selectors
      if pluginName? && eventType?
        selectors = $(@plugins[pluginName].elements[eventType])

      if data instanceof Array
        selectors = selectors.filter(data.join(','))
      else if data instanceof jQuery
        selectors = data

      selectors.off eventName

      selectors

    # builds the object to be passed to the custom send method
    _getTrackObject: (data, event) ->

      # Convert HTML element to a jquery object
      data = $(data) if data instanceof HTMLElement

      if data instanceof jQuery
        $el = data

        $el.data 'track-object',
          location: @_getLocation()
          categories: @_getCategories $el
          value: @_getValue $el

        # run the custom function if its available (and pass in current data)
        $el.data('track-function')? $el.data('track-object'), $el, event

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
      $el.data('track-value') || $el.attr('title') || $el.attr('name') || $el.text().trim() || $el.val() || $el.attr('id') || $el.attr('class')

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

) jQuery, _, window, document
