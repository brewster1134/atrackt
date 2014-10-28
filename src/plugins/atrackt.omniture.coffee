###
Atrackt Omniture Plugin
https://github.com/brewster1134/atrackt
@author Ryan Brewster
@version 1.0.2
###

((root, factory) ->
  if typeof define == 'function' && define.amd
    define [
      'atrackt'
    ], (Atrackt) ->
      factory Atrackt
  else
    factory Atrackt
) @, (Atrackt) ->

  window.Atrackt.setPlugin 'omniture',
    send: (data, options) ->
      return console.error 'ATRACKT ERROR: PLUGIN `omniture` - Site catalyst library not loaded' if typeof s == 'undefined'

      data._categories = data._categories?.join @options.delimiters.category
      data = @translatePropMap data

      @buildSObject data
      if options.page && s.t?
        s.t()
      else if s.tl?
        arg = if options.el?.attr('href')
          options.el[0]
        else
          true
        s.tl arg, options['trackingType'], @buildLinkName data
      data

    options:
      trackingType: 'o'
      charReplaceRegex: /[^\x20-\x7E]/g
      version: 14
      delimiters:
        linkName: '/'
        category: '|'
      linkTrackVars: ['products', 'events']
      propMap:
        _location    : 'prop1'
        _categories  : 'prop2'
        _value       : 'prop3'
        _event       : 'prop4'

    # omniture specific
    buildSObject: (obj) ->
      switch @options.version
        when 14
          linkTrackVars = @options.linkTrackVars
          for key, value of obj
            linkTrackVars.push key
          s.linkTrackVars = linkTrackVars.join(',')

          $.extend s, obj
        when 15
          s.contextData = obj
      s

    buildLinkName: (obj) ->
      linkName = [
        obj[@options.propMap._location]
        obj[@options.propMap._categories]
        obj[@options.propMap._value]
      ]

      linkName.join(@options.delimiters.linkName)

    translatePropMap: (obj) ->
      return obj if @options.version > 14

      _globalData = {}
      $.each obj, (k,v) =>
        _globalData[@keyLookup k] = v?.toString().replace? @options.charReplaceRegex, ''
      _globalData

    keyLookup: (key) ->
      _newKey = @options.propMap[key]
      console.error "ATRACKT ERROR: PLUGIN `omniture` - No mapping for `#{key}` in omniture config" unless _newKey
      _newKey || key
