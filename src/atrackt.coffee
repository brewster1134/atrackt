###
Atrackt Tracking Library
https://github.com/brewster1134/atrackt
@version 1.0.10
@author Ryan Brewster
###

((factory) ->
  if define?.amd
    define [
      'jquery'
    ], ($) ->
      factory $
  else
    factory window.jQuery
) ($) ->

  class Atrackt

    # Default global attributes
    plugins: {}
    _data: {}
    _options: {}
    _elements: {}
    _callbacks: {}

    #
    # PUBLIC METHODS
    #
    setPlugin: (pluginName, plugin) ->
      throw new Error 'ATRACKT ERROR: `setPlugin` - No plugin name defined' unless pluginName
      throw new Error "ATRACKT ERROR: `setPlugin` - No send method was defined for `#{pluginName}`." unless plugin && typeof plugin.send == 'function'

      # Add plugin to global plugins object
      pluginName = pluginName.toLowerCase().replace(/[^a-z]/g, '-')
      @plugins[pluginName] = plugin

      # Set plugin name
      # This value is used to determine if a context is a plugin or on the global Atrackt object
      plugin.name = pluginName

      # Default plugin attributes
      plugin._data ||= {}
      plugin._options ||= {}
      plugin._elements ||={}
      plugin._callbacks ||= {}

      # Pass data to global methods with plugin context
      plugin.setEvent = (eventsObject) => @setEvent eventsObject, plugin
      plugin.setData = (data) => @setData data, plugin
      plugin.setOptions = (options) => @setOptions options, plugin
      plugin.setCallback = (name, callback) => @setCallback name, callback, plugin
      plugin.track = (data, options, event, plugin) => @track data, options, event, plugin

    # Handles registering strings, jquery objects, or html nodes to the plugin
    # Actual event binding is done from _registerElement
    #
    setEvent: (eventsObject, context = @) ->
      throw new Error 'ATRACKT ERROR: `setEvent` - You must pass a valid event object.' unless eventsObject

      for eventType, objects of eventsObject

        # build event namespace
        globalEvent = [eventType, 'atrackt']
        pluginEvent = globalEvent.slice(0)
        pluginEvent.push context.name if context.name

        # typecast objects into an array
        unless objects instanceof Array
          objects = [objects]

        for object in objects
          $(object).each (index, element) =>
            @_elements[eventType] ||= []

            # if binding on a plugin
            # ...and the element has not already been bound globally
            # ...and the element has not already been bound to the plugin
            if context.name
              globalIndex = @_elements[eventType].indexOf(element)

              # if element is not in global array...
              if globalIndex == -1
                context._elements[eventType] ||= []

                # if element is not in plugin array...
                if context._elements[eventType].indexOf(element) == -1
                  @_registerElement context, element, eventType

            # if binding globally
            # ...and the element has not already been bound globally
            else if @_elements[eventType].indexOf(element) == -1
              @_registerElement context, element, eventType

              # loop through plugins and remove global element if it exists
              for pluginName, pluginData of @plugins
                pluginIndex = pluginData._elements[eventType]?.indexOf(element)
                if pluginIndex != -1
                  pluginData._elements[eventType]?.splice pluginIndex, 1

    # Set data that will always be tracked
    #
    setData: (data, context = @) ->
      $.extend true, context._data, data

    # Set options that will always be passed to the send method
    #
    setOptions: (options, context = @) ->
      $.extend true, context._options, options

    # Set callbacks that will be run each time data is tracked
    #
    setCallback: (name, callback, context = @) ->
      allowedCallbacks = [ 'before', 'after' ]

      if allowedCallbacks.indexOf(name) == -1
        throw new Error "ATRACKT ERROR: `setCallback` - `#{name}` is not a valid callback.  Only callbacks allowed are: #{allowedCallbacks.join(', ')}"

      context._callbacks[name] ||= []
      context._callbacks[name].push callback

    # Determine if data can be tracked or not
    #
    track: (data, options = {}, event, context) ->
      # Add the plugin name to the options if it exists
      options['_plugin'] = context.name if context?.name

      trackPlugins = =>
        # Loop through each plugin and check if the data should be tracked
        for pluginName, pluginData of @plugins

          # If tracking is triggered by an event, make sure the event namespace matches the plugin or is global
          if eventNamespace = event?.handleObj?.namespace
            if eventNamespace == 'atrackt' || eventNamespace == "atrackt.#{pluginName}"
              @_trackJqueryObject pluginData, data, options, event

          # If tracking without an event, make sure the _plugin option matches if it is set
          else
            if !options['_plugin'] || options['_plugin'] == pluginName

              # track jQuery objects
              if data instanceof jQuery
                @_trackJqueryObject pluginData, data, options, event

              # track everything else (html element or an object)
              else
                @_track pluginData, data, options, event

      # track with optional delay (in milliseconds)
      delay = options['delay']
      if delay
        setTimeout ->
          trackPlugins()
        , delay
      else
        trackPlugins()

    # Introduce an element into the Atrackt eco-system
    # * add the element to an elements array (global or plugin)
    # * bind the appropriate event (global or plugin)
    #
    _registerElement: (context, element, eventType) ->
      context._elements[eventType].push element

      # create event namespaces
      globalEvent = [eventType, 'atrackt']
      if context.name
        pluginEvent = globalEvent.slice(0)
        pluginEvent.push context.name if context.name
      else
        pluginEvent = globalEvent

      # bind event
      $(element).off globalEvent.join('.')
      $(element).on pluginEvent.join('.'), (e) ->
        context.track @, {}, e

    # Loop through a jquery object and track each element
    #
    _trackJqueryObject: (plugin, data, options, event) ->
      # loop through each jquery object element and track it
      $(data).each (index, element) =>
        @_track plugin, element, options, event

    # Track data with a particular plugin
    # * collect meta data
    # * run callbacks
    # * call plugin send method
    #
    _track: (plugin, data, options, event) ->
      metaData = @_getTrackObject data, event
      throw new Error 'ATRACKT ERROR: `track` - Only valid selectors, jquery objects, or html nodes are supported.' unless metaData

      # prepare tracking data
      trackingData = $.extend true, {}, @_data, plugin._data, options['_data'] || {}, metaData

      # remove any data in the options & plugin options in the global options
      optionsCopy = $.extend true, {}, options, (options[plugin.name] || {})
      delete optionsCopy['_data']
      delete optionsCopy[plugin.name]

      trackingOptions = $.extend true, {}, @_options, plugin._options, optionsCopy

      # run global before callbacks
      for callback in (@_callbacks['before'] || [])
        callback?(trackingData, trackingOptions)

      # run plugin before callbacks
      for callback in (plugin._callbacks['before'] || [])
        callback?(trackingData, trackingOptions)

      # run the custom function if it exists
      if data instanceof jQuery || data.nodeType == 1
        if typeof $(data).data('atrackt-function') == 'function'
          $.proxy($(data).data('atrackt-function'), data)(trackingData, trackingOptions)

      # call plugin's send method
      plugin.send trackingData, trackingOptions

      # run plugin after callbacks
      for callback in (plugin._callbacks['after'] || [])
        callback?(trackingData, trackingOptions)

      # run global after callbacks
      for callback in (@_callbacks['after'] || [])
        callback?(trackingData, trackingOptions)

    # Gets default meta data
    # * add categories and value attributes for elements
    # * add location & event attributes
    #
    _getTrackObject: (data, event) ->
      # add element related data
      if data instanceof jQuery || data.nodeType == 1
        $el = $(data)

        data =
          _categories: @_getCategories $el
          _value: @_getValue $el

      # add location
      data['_location'] = @_getLocation()

      # add event if it exists
      if event?.type
        data['_event'] = event.type

      return data

    # Get the location value
    #
    _getLocation: ->
      $('body').data('atrackt-location')  ||
      $(document).attr('title')           ||
      document.URL

    # Crawl the elements parents and collectiong dom categories
    #
    _getCategories: ($el) ->
      catArray = []

      # add this element's data-track key/value
      catArray.unshift $el.data('atrackt-category') if $el.data('atrackt-category')

      # add this element's parents data-trackkey/value
      $el.parents('[data-atrackt-category]').each ->
        catArray.unshift $(@).data('atrackt-category')

      catArray

    # Get an element value based on a variety of options
    #
    _getValue: ($el) ->
      $el.data('atrackt-value') ||
      $el.val()                 ||
      $el.attr('title')         ||
      $el.attr('name')          ||
      $el.text().trim()         ||
      $el.attr('id')            ||
      $el.attr('class')

  window.Atrackt ||= new Atrackt
