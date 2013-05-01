###
Atrackt Omniture Plugin
https://github.com/brewster1134/atrackt
@author Ryan Brewster
@version 0.0.3
###

window.Atrackt.registerPlugin 'omniture',
  send: (obj, options = {}) ->
    obj.categories = obj.categories?.join @options.delimiters.category
    obj = @translatePropMap obj

    return console.log 'SITE CATALYST SCRIPT NOT LOADED!', obj unless s?

    @buildSObject obj
    if options.page && s.t?
      s.t()
    else if s.tl?
      s.tl true, 'o', @buildLinkName obj
    obj

  options:
    version: 14
    delimiters:
      linkName: '/'
      category: '|'
    propMap:
      plugin      : 'plugin'
      location    : 'prop1'
      categories  : 'prop2'
      value       : 'prop3'
      event       : 'prop4'

  # omniture specific
  buildSObject: (obj) ->
    switch @options.version
      when 14
        linkTrackVars = ['products', 'events']
        for key, value of obj
          linkTrackVars.push key
        s.linkTrackVars = linkTrackVars.join(',')

        $.extend s, obj
      when 15
        s.contextData = obj
    s

  buildLinkName: (obj) ->
    linkName = [
      obj[@options.propMap.location]
      obj[@options.propMap.categories]
      obj[@options.propMap.value]
    ]

    linkName.join(@options.delimiters.linkName)

  translatePropMap: (obj) ->
    return obj if @options.version > 14

    _globalData = {}
    $.each obj, (k,v) =>
      _globalData[@keyLookup k] = v
    _globalData

  keyLookup: (key) ->
    _newKey = @options.propMap[key]
    console.log 'NO MAPPING FOR "' + key + '" FOUND.' unless _newKey
    _newKey || key
