options:
  propLimit: 100
  version: 14
  delimiters:
    linkName: '/'
    category: '|'
  propMap:
    'location'    : 'prop1'
    'categories'  : 'prop2'
    'ctaValue'    : 'prop3'
    'event'       : 'prop4'
    # globalData
    'model'       : 'prop20'
    'trimline'    : 'prop30'

# site catalyst specific
buildSObject = (obj) ->
  switch options.version
    when 14
      varsArray = ['products', 'events']
      eventsArray = []
      for i in Array(options.propLimit)
        varsArray.push('prop' + (_i + 1))
        varsArray.push('eVar' + (_i + 1))
        eventsArray.push('event' + (_i + 1))
      s.linkTrackVars = varsArray.join(',')
      s.linkTrackEvents = eventsArray.join(',')

      $.extend s, obj
    when 15
      s.contextData = obj
  s

buildLinkName = (obj) ->
  linkName = []
  obj.categories = obj.categories.join options.delimiters.category

  switch options.version
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
        obj.ctaValue,
      ]

  linkName.join(options.delimiters.linkName)

window.Atrackt.registerPlugin 'sitecatalyst',
  events:
    click: [ 'a', 'button' ]
  send: (obj) ->
    if s? and s.tl
      buildSObject obj
      s.tl true, 'o', buildLinkName obj
    else
      console.log 'SITECATALYST SCRIPT NOT LOADED!', obj
