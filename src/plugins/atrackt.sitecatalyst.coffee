window.Atrackt.registerPlugin 'siteCatalyst',
  events:
    click: [ 'a', 'button' ]
  send: (obj) ->
    $.extend obj, @translatePropMap obj
    obj.categories = obj.categories.join @options.delimiters.category

    if s? and s.tl
      @buildSObject obj
      s.tl true, 'o', @buildLinkName obj
    else
      console.log 'SITE CATALYST SCRIPT NOT LOADED!', obj

  options:
    propLimit: 100
    version: 14
    delimiters:
      linkName: '/'
      category: '|'
    propMap:
      location    : 'prop1'
      categories  : 'prop2'
      value       : 'prop3'
      event       : 'prop4'
      # globalData
      model       : 'prop20'
      trimline    : 'prop30'

  # siteCatalyst specific
  buildSObject: (obj) ->
    console.log @options.version
    switch @options.version
      when 14
        varsArray = ['products', 'events']
        eventsArray = []
        for i in Array(@options.propLimit)
          varsArray.push('prop' + (_i + 1))
          varsArray.push('eVar' + (_i + 1))
          eventsArray.push('event' + (_i + 1))
        s.linkTrackVars = varsArray.join(',')
        s.linkTrackEvents = eventsArray.join(',')

        $.extend s, obj
      when 15
        s.contextData = obj
    s

  buildLinkName: (obj) ->
    linkName = []

    switch @options.version
      when 14
        linkName = [
          obj.prop1,
          obj.prop2,
          obj.prop3,
        ]
      when 15
        linkName = [
          obj.location,
          obj.categories,
          obj.value,
        ]

    linkName.join(@options.delimiters.linkName)

  translatePropMap: (obj) ->
    return obj if @options.version > 14

    _globalData = {}
    $.each obj, (k,v) ->
      _globalData[keyLookup k] = v
    _globalData

  keyLookup: (key) ->
    _newKey = @options.propMap[key]
    console.log 'No mapping for "' + key + '" found.' unless _newKey
    _newKey || key
