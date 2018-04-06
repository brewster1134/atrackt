###
Atrackt Omniture Plugin
https://github.com/brewster1134/atrackt
@author Ryan Brewster
@version 1.0.6
###

((factory) ->
  if define?.amd
    define [
      'jquery'
      'atrackt'
    ], ($, Atrackt) ->
      factory $, Atrackt
  else
    factory jQuery, Atrackt
) ($, Atrackt) ->

  Atrackt.setPlugin 'omniture',

    # default options
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

    send: (data, options) ->
      # return if the site catalyst library isnt loaded
      return unless s?

      $.extend true, @options, options
      data._categories = data._categories?.join @options.delimiters.category
      data = @_translatePropMap data

      @_buildSObject data
      if @options.page && s.t?
        s.t()
      else if s.tl?
        arg = if @options.el?.attr('href')
          @options.el[0]
        else
          true
        s.tl arg, @options['trackingType'], @_buildLinkName data
      data

    # omniture specific
    _buildSObject: (obj) ->
      switch @options.version
        when 14
          linkTrackVars = @options.linkTrackVars
          for key, value of obj
            linkTrackVars.push key
          s.linkTrackVars = linkTrackVars.join(',')

          $.extend s, obj
        else
          s.contextData = obj
      s

    _buildLinkName: (obj) ->
      linkName = [
        obj[@options.propMap._location]
        obj[@options.propMap._categories]
        obj[@options.propMap._value]
      ]

      linkName.join(@options.delimiters.linkName)

    _translatePropMap: (obj) ->
      return obj if @options.version > 14

      _globalData = {}
      $.each obj, (k,v) =>
        _globalData[@_keyLookup k] = v?.toString().replace? @options.charReplaceRegex, ''
      _globalData

    _keyLookup: (key) ->
      _newKey = @options.propMap[key]
      _newKey || key
