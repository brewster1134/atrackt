describe 'Plugin: SiteCatalyst', ->
  plugin = null

  before ->
    Atrackt.plugins = {}
    loadJs 'js/plugins/atrackt.siteCatalyst'
    plugin = Atrackt.plugins['siteCatalyst']

  after ->
    for event, selectorArray of plugin.events
      $(selectorArray.join(',')).off event

  describe '#buildSObject', ->
    before ->
      window.s = {}
      plugin.options.version = 14
      plugin.options.propLimit = 1
      plugin.buildSObject
        foo: 'bar'

    it 'should add to the s object', ->
      expect(s.foo).to_exist

    it 'shoule create empty props/eVars/events', ->
      console.log s
      expect(s.linkTrackVars).to.equal 'products,events,prop1,eVar1'
      expect(s.linkTrackEvents).to.equal 'event1'

  describe '#keyLookup', ->
    before ->
      plugin.options.propMap =
        foo: 'bar'

    it 'should lookup from propMap', ->
      expect(plugin.keyLookup('foo')).to.equal 'bar'
